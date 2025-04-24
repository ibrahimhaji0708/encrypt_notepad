// use flutter_rust_bridge::frb;
// use std::ffi::CString;

// #[frb]
// pub fn encrypt_message(message: String) -> String {
//     message.chars().rev().collect()
// }



use std::ffi::{CString, CStr};

#[unsafe(no_mangle)]
pub extern "C" fn encrypt_text(text: *const i8) -> *mut i8 {
    // Convert the pointer to a Rust string
    let c_str = unsafe { CStr::from_ptr(text) };
    let message = c_str.to_str().unwrap();

    // Perform encryption logic (mocked here)
    let encrypted_message = format!("Encrypted: {}", message);

    // Convert encrypted message back to CString for FFI compatibility
    CString::new(encrypted_message).unwrap().into_raw()
}

#[unsafe(no_mangle)]
pub extern "C" fn decrypt_text(text: *const i8) -> *mut i8 {
    // Decryption logic (mocked here)
    let c_str = unsafe { CStr::from_ptr(text) };
    let message = c_str.to_str().unwrap();

    let decrypted_message = format!("Decrypted: {}", message);
    CString::new(decrypted_message).unwrap().into_raw()
}
