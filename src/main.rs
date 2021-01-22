extern crate clap;

use clap::{App, Arg, ArgMatches};
use glob::{glob, Paths, PatternError};
use is_executable::IsExecutable;
use serde_json::map::Map;
use serde_json::Value;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};

struct FileData {
    year: u16,
    month: u8,
    day: u8,
    hour: u8,
    minute: u8,
    second: u8,
    hash: String,
    smallhash: String,
    city: Option<String>,
    state: Option<String>,
    country: Option<String>,
    camera: Option<String>,
    extension: String,
    original: String,
}

fn main() {
    let matches: ArgMatches = App::new("Fotz")
        .version("0.1.0")
        .author("Éber F. Dias <eber.freitas@gmail.com>")
        .about("Photos and videos organizer.")
        .arg(
            Arg::with_name("source")
                .short("s")
                .long("source")
                .value_name("SOURCE_DIR")
                .help("Source directory")
                .takes_value(true)
                .required(true),
        )
        .arg(
            Arg::with_name("dest")
                .short("d")
                .long("dest")
                .value_name("DEST_DIR")
                .help("Destination directory")
                .takes_value(true)
                .required(true),
        )
        .arg(
            Arg::with_name("exiftool")
                .short("e")
                .long("exiftool")
                .value_name("EXIFTOOL")
                .help("Path to the ExifTool executable")
                .takes_value(true)
                .required(false),
        )
        .get_matches();

    let exiftool: &str = match matches.value_of("exiftool") {
        Some(val) => val,
        None => "exiftool",
    };

    has_exiftool(exiftool);

    let source_dir: &str = matches.value_of("source").unwrap();
    let exts: [&str; 12] = [
        "jpg", "JPG", "jpeg", "JPEG", "mov", "MOV", "mp4", "MP4", "mpg", "MPG", "avi", "AVI",
    ];
    let mut paths: Vec<PathBuf> = Vec::new();
    let mut entries: Result<Paths, PatternError>;

    for ext in exts.iter() {
        entries = glob(&format!("{}/**/*.{}", source_dir, ext));

        for entry in entries.unwrap() {
            if let Ok(path) = entry {
                paths.push(path)
            }
        }
    }

    paths.sort_unstable();
    paths.dedup();

    println!("Found {} image(s)", paths.len());

    for p in paths {
        let exif_data = get_file_exif_data(&exiftool, &p);

        println!("{:?}", exif_data);
    }
}

fn has_exiftool(path: &str) {
    let path: &Path = Path::new(path);

    if !path.is_executable() {
        println!("Could not find the ExifTool executable.");
        std::process::exit(0);
    }
}

fn get_file_exif_data(exiftool: &str, path: &Path) -> Value {
    let output: Output = Command::new(exiftool)
        .arg("-q")
        .arg("-json")
        .arg(path)
        .output()
        .expect("Could not run ExifTool on the given file.");

    let json: String = String::from_utf8(output.stdout).expect("Invalid JSON data from ExifTool.");
    let val: Value = serde_json::from_str(&json).expect("Error parsing JSON value.");
    let r: Option<Value> = if let Value::Array(arr) = val {
        arr.into_iter().next()
    } else {
        None
    };

    r.unwrap_or_else(|| Value::Object(Map::new()))
}
