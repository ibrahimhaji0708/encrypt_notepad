use std::ffi::{c_char, CStr};
use std::fs::{self, File};
use std::io::Read;
use flutter_rust_bridge::frb;
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
        .unwrap_or_else(|_| "Untitled");
    let content = unsafe { CStr::from_ptr(content) }
        .to_str()
        .unwrap_or_else(|_| ""); 

    let mut file_path = notes_dir();
    file_path.push(format!("{title}.txt"));

    match fs::write(file_path, content) {
        Ok(_) => println!("Note saved: {title}"),
        Err(e) => eprintln!("Error saving note: {:#?}", e),
    }
}



#[frb]
pub fn load_note_from_disk(note_title: String) -> Result<String, String> {
    let mut file_path = notes_dir();
    file_path.push(format!("{}.txt", note_title));

    let mut file = File::open(file_path).map_err(|e| e.to_string())?;
    let mut content = String::new();
    file.read_to_string(&mut content).map_err(|e| e.to_string())?;
    Ok(content)
}

#[frb]
pub fn list_note_titles() -> Result<Vec<String>, String> {
    let dir = notes_dir();
    let mut titles = Vec::new();

    if dir.exists() {
        for entry in fs::read_dir(dir).map_err(|e| e.to_string())? {
            if let Ok(entry) = entry {
                if let Some(name) = entry.file_name().to_str() {
                    if let Some(stripped) = name.strip_suffix(".txt") {
                        titles.push(stripped.to_string());
                    }
                }
            }
        }
    }

    Ok(titles)
}
