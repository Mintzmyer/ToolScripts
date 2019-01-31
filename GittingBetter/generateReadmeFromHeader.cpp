/* This file updates a README.md file with the header
 * block comments of the files it is fed. 
 *
 * Calling it with just a directory erases the README.md file
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

// Global debug variable for print statements
bool DEBUG=false;

/* A print function for debugging
 *  Checks the DEBUG flag, and either prints or ignores
 *  the statement
 */
void debugPrint(string debugStatement) {
    if (DEBUG) {
        cout << debugStatement << endl;
    }
}

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

/*
 *
 */
string tidyComment(string commentRaw, string artifacts[], int size) {
    for (int i = 0; i < size; i++) {
        // Remove all unwanted symbols
        commentRaw = removeAllSubstr(commentRaw, artifacts[i]);
    }
    return commentRaw;
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
    if ((fileExt.compare(".sh") == 0) || (fileExt.compare(".py") == 0)) {
        startSymbol = "\n# ";
        endSymbol = "\n\n";

	// Cut comment to size
        startLoc = fileContents.find(startSymbol);
        endLoc = fileContents.find(endSymbol);
        fileContents.erase(endLoc, string::npos);
        fileContents.erase(0, startLoc);
        fileContents = removeAllSubstr(fileContents, "#");
	// Remove extra artifacts and symbols
	string rmSubstrs[] = {"#"};
	fileContents = tidyComment(fileContents, rmSubstrs, 1);
    } else if ((fileExt.compare(".h") == 0) 
            || (fileExt.compare(".c") == 0)
            || (fileExt.compare(".cpp") == 0)) {
        startSymbol = "/*";
        endSymbol = "*/";

	// Cut comment to size
        endLoc = fileContents.find(endSymbol);
        startLoc = fileContents.find(startSymbol);
        fileContents.erase(0, startLoc);
        fileContents.erase(endLoc+2, string::npos);
	// Remove extra artifacts and symbols
	string rmSubstrs[] = {"/*", "*/", "*"};
        fileContents = tidyComment(fileContents, rmSubstrs, 3);

    } else {
        cout << fileRaw << " Error: cannot tell how comments are delineated\n"
                            "from code based on the file extension\n";
    }
    return fileContents;
}

/* Writes to README.md
 * If append is true, appends. Otherwise, overwrites
 */
void writeToReadMe(string comment, string directoryRaw, bool append){
    ofstream wReadMeFile;
    string thisReadme = directoryRaw;
    thisReadme.append("README.md");
    debugPrint(" --- writeToReadMe - thisReadme: " + thisReadme);

    if (append) {
        wReadMeFile.open(thisReadme, fstream::app);
    } else {
        wReadMeFile.open(thisReadme);
    }
    wReadMeFile << comment;
    return;
}

/* Preps the README file by removing any previously
 * generated headers so updated ones can be written
 */
void prepReadMeFile(string directoryRaw){
    // Read in contents of README
    ostringstream readMeContents;
    string thisReadme = directoryRaw;
    thisReadme.append("README.md");
    debugPrint(" --- thisReadme: " + thisReadme);

    ifstream rReadMeFile(thisReadme);

    readMeContents << rReadMeFile.rdbuf();
    string editableReadMe = readMeContents.str();
    string beginAutoGen = "###### Auto-Generated Documentation\n";
    size_t rmAfter = editableReadMe.find(beginAutoGen);

    if (rmAfter != string::npos) {
        editableReadMe.erase(rmAfter, string::npos);
    }

    // Add fresh tag and write back contents of README
    editableReadMe.append(beginAutoGen);
    debugPrint(" --- editableReadMe:\n" + editableReadMe);

    writeToReadMe(editableReadMe, directoryRaw, false);
}

/* Encapsulates the main logic flow for updating
 *  the README
 */
void updateReadMe(string fileRaw, string directoryRaw) {
    if (isFileValid(fileRaw)) {
        // Extract file header comments
        string header = extractHeader(directoryRaw+fileRaw);
        header.append("\n");
        debugPrint(" -- Header gathered:\n" + header);

        // Compose new file section
        string fileSection = "### ";
        fileSection.append(fileRaw);
        fileSection.append("\n");
        debugPrint(" -- fileSection gathered: " + fileSection);

        // Write new file section and comments
        writeToReadMe(fileSection, directoryRaw, true);
        writeToReadMe(header, directoryRaw, true);
    } else {
        cout << "Ignoring "<<fileRaw<<": Invalid file\n";
    }
}

int main(int argc, char *argv[]){
    if (argc == 1) {
        cout << "call with: <directory> [file]";
        debugPrint(" -- No arguments given: Needs at least a directory");
        return 0;
    }

    string directory = argv[1];
    if (directory.back() != ('/')) {//!= 0) {
        directory.append("/");
    }
    debugPrint(" -- Directory: " + directory);
    // Remove all auto-gen documentation only once
    if (argc == 2) {
        prepReadMeFile(directory);
    } else {
        string file = argv[2];
        debugPrint(" -- File: " + file);
        updateReadMe(file, directory);
    }
    return 0;
}
