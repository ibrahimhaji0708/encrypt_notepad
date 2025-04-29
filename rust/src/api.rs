use std::ffi::{c_char, CStr, CString};
use std::fs;
use std::path::PathBuf;

fn notes_dir() -> PathBuf {
    let mut dir = std::env::current_dir().unwrap_or_default();
    dir.push("notes");
    if !dir.exists() {
        fs::create_dir_all(&dir).unwrap();
    }
    dir
}

#[unsafe(no_mangle)]
pub extern "C" fn save_note_to_disk(title: *const c_char, content: *const c_char) {
    let title = unsafe { CStr::from_ptr(title) }
        .to_str()
        .unwrap_or("Untitled");
    let content = unsafe { CStr::from_ptr(content) }
        .to_str()
        .unwrap_or("");

    let mut path = notes_dir();
    path.push(format!("{title}.txt"));

    if let Err(e) = fs::write(&path, content) {
        eprintln!("Failed to save note: {e}");
    } else {
        println!("Note saved: {title}");
    }
}
//corrected code for load_note_func 
#[unsafe(no_mangle)]
pub extern "C" fn load_note_from_disk(title: *const c_char) -> *mut c_char {
    let title_str = unsafe { CStr::from_ptr(title).to_str().unwrap_or("Untitled") };

    let mut path = notes_dir();
    path.push(format!("{title_str}.txt"));

    let content = fs::read_to_string(&path).unwrap_or_default();
    let c_string = CString::new(content).unwrap();
    c_string.into_raw()
}


#[unsafe(no_mangle)]
pub extern "C" fn list_note_titles() -> *mut c_char {
    let dir = notes_dir();
    let mut titles = Vec::new();

    if dir.exists() {
        let entries = fs::read_dir(dir).unwrap();

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

    let titles_str = titles.join(";");
    let c_string = CString::new(titles_str).unwrap();
    c_string.into_raw()
}

// free up memory 
#[unsafe(no_mangle)]
pub extern "C" fn free_string(ptr: *mut c_char) {
    unsafe {
        if ptr.is_null() { return; }
        let _ = CString::from_raw(ptr); // will drop and free memory
    }
}
