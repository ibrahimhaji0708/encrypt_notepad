use std::ffi::{c_char, CStr, CString};
use std::fs::{self, File};
use std::path::PathBuf;
use std::io::{self, Write};
use std::sync::Once;

static ENCRYPTION_KEY: &[u8] = b"NOTEPAD_SECRET_KEY_2025";
static INIT: Once = Once::new();

fn initialize() {
    let dir = notes_dir();
    if !dir.exists() {
        if let Err(e) = fs::create_dir_all(&dir) {
            eprintln!("Failed to create notes directory: {}", e);
        } else {
            println!("Notes directory created at: {:?}", dir);
        }
    }
}

fn notes_dir() -> PathBuf {
    let mut dir = std::env::current_dir().unwrap_or_default();
    dir.push("notes");
    dir
}

fn ensure_directory_exists() -> io::Result<PathBuf> {
    INIT.call_once(|| {
        initialize();
    });
    
    let dir = notes_dir();
    if !dir.exists() {
        fs::create_dir_all(&dir)?;
    }
    Ok(dir)
}

fn xor_encrypt_decrypt(data: &[u8]) -> Vec<u8> {
    data.iter()
        .zip(ENCRYPTION_KEY.iter().cycle())
        .map(|(&b, &k)| b ^ k)
        .collect()
}

fn c_char_to_string(c_str: *const c_char) -> Result<String, &'static str> {
    if c_str.is_null() {
        return Err("Null pointer provided");
    }
    
    unsafe {
        match CStr::from_ptr(c_str).to_str() {
            Ok(s) => Ok(s.to_string()),
            Err(_) => Err("Invalid UTF-8 string"),
        }
    }
}
//uncmt if error
// #[unsafe(no_mangle)]
// pub extern "C" fn save_note_to_disk(title: *const c_char, content: *const c_char) {
//     let title = match c_char_to_string(title) {
//         Ok(s) => s,
//         Err(e) => {
//             eprintln!("Error reading title: {}", e);
//             return;
//         }
//     };
    
//     let content = match c_char_to_string(content) {
//         Ok(s) => s,
//         Err(e) => {
//             eprintln!("Error reading content: {}", e);
//             return;
//         }
//     };
    
//     let dir = match ensure_directory_exists() {
//         Ok(dir) => dir,
//         Err(e) => {
//             eprintln!("Failed to create notes directory: {}", e);
//             return;
//         }
//     };
    
//     let mut path = dir;
//     path.push(format!("{}.txt", title));
    
//     //enc beofre save
//     let encrypted_data = xor_encrypt_decrypt(content.as_bytes());
    
//     if let Err(e) = fs::write(&path, encrypted_data) {
//         eprintln!("Failed to save note: {}", e);
//     } else {
//         println!("Note saved successfully: {}", title);
//     }
// }
//another savenote func
#[unsafe(no_mangle)]
pub extern "C" fn save_note_to_disk(title: *const c_char, content: *const c_char) -> bool {
    if title.is_null() || content.is_null() {
        eprintln!("[Rust] Null pointer received");
        return false;
    }

    let title = match unsafe { CStr::from_ptr(title).to_str() } {
        Ok(s) => s.to_string(),
        Err(e) => {
            eprintln!("[Rust] Invalid title UTF-8: {}", e);
            return false;
        }
    };

    let content = match unsafe { CStr::from_ptr(content).to_str() } {
        Ok(s) => s.to_string(),
        Err(e) => {
            eprintln!("[Rust] Invalid content UTF-8: {}", e);
            return false;
        }
    };

    let sanitized = title.replace(|c: char| !c.is_alphanumeric(), "_");
    let path = PathBuf::from(format!("/storage/emulated/0/Notes/{}.txt", sanitized));

    if let Some(parent) = path.parent() {
        if let Err(e) = fs::create_dir_all(parent) {
            eprintln!("[Rust] Failed to create folder: {}", e);
            return false;
        }
    }

    let encrypted = xor_encrypt_decrypt(content.as_bytes());

    match File::create(&path).and_then(|mut f| f.write_all(&encrypted)) {
        Ok(_) => {
            println!("[Rust] Saved note to {:?}", path);
            true
        }
        Err(e) => {
            eprintln!("[Rust] File write failed: {}", e);
            false
        }
    }
}
// fn get_android_notes_dir() -> Result<PathBuf, io::Error> {
//     let path = PathBuf::from("/storage/emulated/0/Notes");
//     fs::create_dir_all(&path)?;
//     Ok(path)
// }

#[unsafe(no_mangle)]
pub extern "C" fn load_note_from_disk(title: *const c_char) -> *mut c_char {
    let title_str = match c_char_to_string(title) {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    
    let dir = match ensure_directory_exists() {
        Ok(dir) => dir,
        Err(_) => return std::ptr::null_mut(),
    };
    
    let mut path = dir;
    path.push(format!("{}.txt", title_str));
    
    match fs::read(&path) {
        Ok(encrypted_bytes) => {
            //decrypt content
            let decrypted_bytes = xor_encrypt_decrypt(&encrypted_bytes);
            
            match String::from_utf8(decrypted_bytes) {
                Ok(content) => {
                    match CString::new(content) {
                        Ok(c_string) => c_string.into_raw(),
                        Err(_) => std::ptr::null_mut(),
                    }
                },
                Err(_) => {
                    eprintln!("Failed to decode file content as UTF-8");
                    CString::new("").unwrap_or_default().into_raw()
                }
            }
        },
        Err(e) => {
            eprintln!("Failed to read note {}: {}", title_str, e);
            CString::new("").unwrap_or_default().into_raw()
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn list_note_titles() -> *mut c_char {
    let dir = match ensure_directory_exists() {
        Ok(dir) => dir,
        Err(_) => return CString::new("").unwrap_or_default().into_raw(),
    };
    
    let mut titles = Vec::new();
    
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries {
            if let Ok(entry) = entry {
                if let Some(name) = entry.file_name().to_str() {
                    if let Some(title) = name.strip_suffix(".txt") {
                        titles.push(title.to_string());
                    }
                }
            }
        }
    }
    
    titles.sort();
    
    let titles_str = titles.join(";");
    
    match CString::new(titles_str) {
        Ok(c_string) => c_string.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn free_string(ptr: *mut c_char) {
    unsafe {
        if !ptr.is_null() {
            let _ = CString::from_raw(ptr);
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn delete_note_from_disk(title: *const c_char) {
    let title_str = match c_char_to_string(title) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("Error reading title for deletion: {}", e);
            return;
        }
    };
    
    let dir = match ensure_directory_exists() {
        Ok(dir) => dir,
        Err(e) => {
            eprintln!("Failed to access notes directory for deletion: {}", e);
            return;
        }
    };
    
    let mut path = dir;
    path.push(format!("{}.txt", title_str));
    
    if let Err(e) = fs::remove_file(&path) {
        eprintln!("Failed to delete note {}: {}", title_str, e);
    } else {
        println!("Note deleted successfully: {}", title_str);
    }
}

fn base64_encode(data: &[u8]) -> String {
    const ALPHABET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut result = String::with_capacity((data.len() + 2) / 3 * 4);
    
    for chunk in data.chunks(3) {
        let b0 = chunk[0] as u32;
        let b1 = if chunk.len() > 1 { chunk[1] as u32 } else { 0 };
        let b2 = if chunk.len() > 2 { chunk[2] as u32 } else { 0 };
        
        let triple = (b0 << 16) | (b1 << 8) | b2;
        
        result.push(ALPHABET[(triple >> 18) as usize] as char);
        result.push(ALPHABET[((triple >> 12) & 0x3F) as usize] as char);
        
        if chunk.len() > 1 {
            result.push(ALPHABET[((triple >> 6) & 0x3F) as usize] as char);
        } else {
            result.push('=');
        }
        
        if chunk.len() > 2 {
            result.push(ALPHABET[(triple & 0x3F) as usize] as char);
        } else {
            result.push('=');
        }
    }
    
    result
}

#[unsafe(no_mangle)]
pub extern "C" fn encrypt_text(text: *const c_char) -> *mut c_char {
    let text_str = match c_char_to_string(text) {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    
    let encrypted_bytes = xor_encrypt_decrypt(text_str.as_bytes());
    let encoded = base64_encode(&encrypted_bytes);
    
    let encrypted = format!("🔒 {}", encoded);
    
    match CString::new(encrypted) {
        Ok(c_string) => c_string.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}
