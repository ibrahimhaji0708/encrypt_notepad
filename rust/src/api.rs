use std::ffi::{c_char, CStr, CString};
use std::fs::{self, File};
use std::io::Read;
use std::path::PathBuf;
use flutter_rust_bridge::frb;

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

#[frb]
pub fn load_note_from_disk(note_title: String) -> Result<String, String> {
    let mut path = notes_dir();
    path.push(format!("{note_title}.txt"));
    let mut file = File::open(path).map_err(|e| e.to_string())?;
    let mut content = String::new();
    file.read_to_string(&mut content).map_err(|e| e.to_string())?;
    Ok(content)
}

#[unsafe(no_mangle)]
pub extern "C" fn list_note_titles() -> *mut c_char {
    let titles = "title1;title2;title3"; // static input 
    let c_string = CString::new(titles).unwrap();
    c_string.into_raw()
    // let dir = notes_dir();
    // let mut titles = Vec::new();

    // if dir.exists() {
    //     for entry in fs::read_dir(dir).map_err(|e| e.to_string())? {
    //         if let Ok(entry) = entry {
    //             if let Some(name) = entry.file_name().to_str() {
    //                 if let Some(title) = name.strip_suffix(".txt") {
    //                     titles.push(title.to_string());
    //                 }
    //             }
    //         }
    //     }
    // }
    // Ok(titles)
}
