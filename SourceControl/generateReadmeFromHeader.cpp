/* This file updates a README.md file with the header
 * block comments of the files it is fed. 
 *
 * Calling it with no arguements erases the README.md file
 * after a tag marking the auto-generated portion 
 * (allowing for static overarching directory comments
 * to remain untouched)
 * 
 * Passing it files lets it extract and append their
 * headers to the README.md file
 *
 * It is implemented in C++ with the hope that it is
 * OS agnostic, and has an accompanying shell script
 * to invoke it in a linux/unix environment. A similar
 * batch file would permit it to run on Windows
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>

using namespace std;

/* Searches a string for a substring and, if found
 *  removes all instances of it. Then returns the
 *  newly altered string
 */
string removeAllSubstr(string str, string substr) {
    size_t pos = string::npos;

    while ((pos = str.find(substr) ) != string::npos) {
        str.erase(pos, substr.length());
    }
    return str;
}

/*  Checks the input file for validity
 *  Ignores files without an extension
 */
bool isFileValid(string fileRaw){
    // Don't recursively add README's documentation to README
    if (fileRaw.compare("README.md") == 0) {
        return false;
    }
    auto const posSlash=fileRaw.find_last_of('/');
    const auto fileName=fileRaw.substr(posSlash+1);
    const auto posDot=fileName.find_last_of('.');
    return (posDot != std::string::npos);
}

/* Pulls out comment header block based
 * on file type
 */
string extractHeader(string fileRaw){
    ostringstream fileContentsStream;
    ifstream readFile(fileRaw);
    fileContentsStream << readFile.rdbuf();
    string fileContents = fileContentsStream.str();

    const auto posDot=fileRaw.find_last_of('.');
    const auto fileExt=fileRaw.substr(posDot);

    string startSymbol, endSymbol;
    size_t startLoc, endLoc;
    
    // Find header comment block based on file type
    if (fileExt.compare(".sh") == 0) {
        startSymbol = "#!/bin/bash\n";
        endSymbol = "\n\n";
        startLoc = fileContents.find_first_not_of(startSymbol);
        endLoc = fileContents.find(endSymbol);
        fileContents.erase(endLoc, string::npos);
        fileContents.erase(0, startLoc);
        fileContents = removeAllSubstr(fileContents, "#");
    } else if ((fileExt.compare(".h") == 0) 
            || (fileExt.compare(".c") == 0)
            || (fileExt.compare(".cpp") == 0)) {
        startSymbol = "/*";
        endSymbol = "*/";
        endLoc = fileContents.find(endSymbol);
        startLoc = fileContents.find(startSymbol);
        fileContents.erase(0, startLoc);
        fileContents.erase(endLoc+2, string::npos);
        fileContents = removeAllSubstr(fileContents, "/*");
        fileContents = removeAllSubstr(fileContents, "*/");
        fileContents = removeAllSubstr(fileContents, "*");
    } else {
        cout << fileRaw << " Error: cannot tell how comments are delineated\n"
                            "from code based on the file extension\n";
    }
    return fileContents;
}

/* Writes to README.md
 * If append is true, appends. Otherwise, overwrites
 */
void writeToReadMe(string comment, bool append){
    ofstream wReadMeFile;
    if (append) {
        wReadMeFile.open("README.md", fstream::app);
    } else {
        wReadMeFile.open("README.md");
    }
    wReadMeFile << comment;
    return;
}

/* Preps the README file by removing any previously
 * generated headers so updated ones can be written
 */
void prepReadMeFile(){
    // Read in contents of README
    ostringstream readMeContents;
    ifstream rReadMeFile("README.md");

    readMeContents << rReadMeFile.rdbuf();
    string editableReadMe = readMeContents.str();
    string beginAutoGen = "###### Auto-Generated Documentation\n";
    size_t rmAfter = editableReadMe.find(beginAutoGen);

    if (rmAfter != string::npos) {
        editableReadMe.erase(rmAfter, string::npos);
    }

    // Add fresh tag and write back contents of README
    editableReadMe.append(beginAutoGen);
    writeToReadMe(editableReadMe, false);
}

/* Encapsulates the main logic flow for updating
 *  the README
 */
void updateReadMe(string fileRaw) {
    if (isFileValid(fileRaw)) {
        // Extract file header comments
        string header = extractHeader(fileRaw);
        header.append("\n");
        // Compose new file section
        string fileSection = "### ";
        fileSection.append(fileRaw);
        fileSection.append("\n");
        // Write new file section and comments
        writeToReadMe(fileSection, true);
        writeToReadMe(header, true);
    } else {
        cout << "Ignoring "<<fileRaw<<": Invalid file\n";
    }
}

int main(int argc, char *argv[]){
    // Remove all auto-gen documentation only once
    if (argc == 1) {
        prepReadMeFile();
    } else {
        string directory = argv[1];
        string file = argv[2];
        updateReadMe(file);
    }
    return 0;
}
