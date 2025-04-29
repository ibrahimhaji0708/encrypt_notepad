use std::ffi::{c_char, CStr, CString};
use std::fs;
use std::path::PathBuf;

fn notes_dir() -> PathBuf {
    let mut dir = std::env::current_dir().unwrap_or_default();
    dir.push("notes");
    if !dir.exists() {
        let _ = fs::create_dir_all(&dir);
    }
    dir
}

#[unsafe(no_mangle)]
pub extern "C" fn save_note_to_disk(title: *const c_char, content: *const c_char) {
    let title = unsafe {
        if title.is_null() {
            return;
        }
        match CStr::from_ptr(title).to_str() {
            Ok(s) => s,
            Err(_) => return,
        }
    };
    
    let content = unsafe {
        if content.is_null() {
            return;
        }
        match CStr::from_ptr(content).to_str() {
            Ok(s) => s,
            Err(_) => return,
        }
    };
    
    let mut path = notes_dir();
    path.push(format!("{}.txt", title));
    
    if let Err(e) = fs::write(&path, content) {
        eprintln!("Failed to save note: {}", e);
    } else {
        println!("Note saved: {}", title);
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn load_note_from_disk(title: *const c_char) -> *mut c_char {
    let title_str = unsafe {
        if title.is_null() {
            return std::ptr::null_mut();
        }
        match CStr::from_ptr(title).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        }
    };
    
    let mut path = notes_dir();
    path.push(format!("{}.txt", title_str));
    
    match fs::read_to_string(&path) {
        Ok(content) => {
            match CString::new(content) {
                Ok(c_string) => c_string.into_raw(),
                Err(_) => std::ptr::null_mut(),
            }
        },
        Err(_) => {
            // Return empty string instead of null
            match CString::new("") {
                Ok(c_string) => c_string.into_raw(),
                Err(_) => std::ptr::null_mut(),
            }
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn list_note_titles() -> *mut c_char {
    let dir = notes_dir();
    let mut titles = Vec::new();
    
    if dir.exists() {
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
    }
    
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
pub extern "C" fn encrypt_text(text: *const c_char) -> *mut c_char {
    let text_str = unsafe {
        if text.is_null() {
            return std::ptr::null_mut();
        }
        match CStr::from_ptr(text).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        }
    };
    
    let encrypted = format!("ENCRYPTED:{}", text_str);
    
    match CString::new(encrypted) {
        Ok(c_string) => c_string.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}