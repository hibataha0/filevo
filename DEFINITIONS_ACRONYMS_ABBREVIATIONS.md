# Definitions, Acronyms, and Abbreviations - FileVO

## 1.3 Definitions, Acronyms, and Abbreviations

This section provides definitions of terms, acronyms, and abbreviations used throughout the FileVO documentation.

### A

**API (Application Programming Interface)**
An interface that allows different software components to communicate with each other. In FileVO, RESTful APIs are used for client-server communication.

**Android**
A mobile operating system developed by Google, one of the supported platforms for FileVO.

**Authentication**
The process of verifying a user's identity, typically through email and password, email verification codes, or biometric methods in FileVO.

**Authorization**
The process of determining whether an authenticated user has permission to access specific resources or perform certain actions.

---

### B

**Backend**
The server-side component of FileVO that handles business logic, database operations, API endpoints, and file storage management.

**Bearer Token**
A type of access token used in authentication. FileVO uses Bearer tokens to authorize API requests after user login.

**Biometric Authentication**
A security mechanism that uses biological characteristics (fingerprint, face recognition) to verify user identity. Used in FileVO for folder protection.

---

### C

**Category**
A classification system for organizing files by type (e.g., Documents, Images, Videos, Audio, Archives). Files in FileVO are automatically categorized based on their file extension or MIME type.

**Client**
The application or device that requests services from the server. In FileVO, the Flutter mobile/desktop app acts as the client.

**Cloud Storage**
Remote storage infrastructure accessed over the internet. FileVO provides cloud-based file storage capabilities.

**CRUD**
Create, Read, Update, Delete - the four basic operations for persistent storage. FileVO implements CRUD operations for files, folders, and users.

---

### D

**Database**
A structured collection of data. FileVO uses MongoDB as its database to store files metadata, user information, rooms, and other system data.

**Dark Mode / Light Mode**
User interface themes that adjust color schemes for comfortable viewing in different lighting conditions. FileVO supports both themes.

**Dart**
The programming language used to develop the Flutter frontend application of FileVO.

**Desktop Application**
A software application that runs on desktop operating systems. FileVO supports Windows, Linux, and macOS desktop platforms.

**Download**
The process of transferring a file from the server to a user's local device.

---

### E

**Email Verification**
A security process that confirms a user's email address by sending a verification code. Used in FileVO during registration and email changes.

---

### F

**File**
A digital resource stored in the FileVO system, containing data such as documents, images, videos, or other media types.

**File Extension**
A suffix appended to a filename indicating the file type (e.g., .pdf, .jpg, .mp4). Used by FileVO for automatic categorization.

**File Metadata**
Information about a file, including name, size, type, creation date, modification date, and location. Stored in the database separate from the file content.

**File Preview**
A feature that allows users to view file contents without downloading the entire file. FileVO supports previews for PDFs, images, videos, audio, and text files.

**FileVO**
The name of the file storage and management system described in this documentation.

**Flutter**
A cross-platform UI framework developed by Google, used to build the FileVO frontend application for mobile and desktop platforms.

**Folder**
A virtual container used to organize files in a hierarchical structure. Folders can contain files and subfolders, creating a tree-like organization system.

**Folder Hierarchy**
A tree-like structure where folders can contain subfolders, allowing nested organization of files and folders.

**Frontend**
The client-side application that users interact with. In FileVO, the frontend is built using Flutter and runs on mobile and desktop devices.

---

### G

**GB (Gigabyte)**
A unit of digital storage equal to 1,024 megabytes. FileVO provides default storage quotas of 10 GB per user.

---

### H

**HTTPS (Hypertext Transfer Protocol Secure)**
A secure version of HTTP that encrypts data transmitted between client and server. Recommended for FileVO API communication.

**Hugging Face**
An AI/ML platform providing pre-trained models. FileVO uses Hugging Face models for semantic search functionality.

---

### I

**iOS**
Apple's mobile operating system, one of the supported platforms for FileVO.

---

### J

**JSON (JavaScript Object Notation)**
A lightweight data interchange format. FileVO uses JSON for API request/response payloads and data storage.

---

### M

**macOS**
Apple's desktop operating system, one of the supported platforms for FileVO.

**Member**
A user who has been invited and joined a Room in FileVO, with access to shared files and folders within that room.

**MIME Type (Multipurpose Internet Mail Extensions)**
A standard indicating the nature and format of a file (e.g., application/pdf, image/jpeg). Used by FileVO for file type identification and categorization.

**Mobile Application**
A software application designed to run on mobile devices. FileVO provides mobile apps for Android and iOS.

**MongoDB**
A NoSQL document-oriented database used by FileVO's backend to store application data.

**Multilingual Support**
The ability of an application to support multiple languages. FileVO supports Arabic and English with full localization.

---

### N

**Node.js**
A JavaScript runtime environment used to build the backend server for FileVO.

**Notification**
A real-time alert or message informing users about system events, such as file updates, shared content, or access requests. FileVO uses Socket.IO for real-time notifications.

---

### O

**One-Time Access Link**
A temporary, single-use link for accessing shared files securely. Used in FileVO for secure temporary file sharing.

---

### P

**PDF (Portable Document Format)**
A file format for documents. FileVO supports PDF viewing and preview.

**Permission**
An authorization rule that determines what actions a user can perform on a resource (file or folder) in FileVO.

**Platform**
An operating system or environment where software runs. FileVO supports multiple platforms: Android, iOS, Web, Windows, Linux, and macOS.

**Provider**
A state management pattern/package used in Flutter. FileVO uses the Provider package for managing application state.

**Pull-to-Refresh**
A user interface gesture that allows users to update content by pulling down. Implemented in FileVO for refreshing file lists and folder contents.

---

### R

**Real-Time**
Communication or updates that occur instantaneously. FileVO uses Socket.IO for real-time notifications and updates.

**REST (Representational State Transfer)**
An architectural style for designing web services. FileVO's API follows REST principles.

**RESTful API**
An API that adheres to REST principles, using standard HTTP methods (GET, POST, PUT, DELETE) for operations.

**Room**
A collaborative workspace in FileVO where users can share files and folders, invite members, and collaborate on projects.

---

### S

**Search**
A functionality that allows users to find files and folders by name, content, or semantic meaning. FileVO provides both traditional and AI-powered semantic search.

**Semantic Search**
An advanced search method that understands the meaning and context of queries, not just keyword matching. FileVO uses Hugging Face models for semantic search.

**Server**
A computer system that provides services or resources to clients. FileVO's backend runs on a server, handling API requests and file storage.

**Session**
A period of user interaction with the application. FileVO manages sessions using tokens.

**Socket.IO**
A JavaScript library that enables real-time, bidirectional communication between client and server. Used in FileVO for real-time notifications and updates.

**Soft Delete**
A deletion method where data is marked as deleted but not permanently removed from the database. FileVO implements soft delete through the Trash system.

**Starred Files**
Files marked as favorites by users for quick access. Also referred to as favorite files in FileVO.

**Storage Limit / Storage Quota**
The maximum amount of storage space allocated to a user. FileVO provides a default quota of 10 GB per user.

**Storage Used**
The amount of storage space currently utilized by a user's files in FileVO.

---

### T

**Token**
A credential used for authentication and authorization. FileVO uses Bearer tokens to authenticate API requests.

**Trash**
A temporary storage location for deleted files in FileVO, allowing users to recover accidentally deleted files before permanent deletion.

**Tree Structure / Hierarchy**
An organizational structure where items (files/folders) are arranged in a parent-child relationship, forming a tree-like structure.

---

### U

**Upload**
The process of transferring a file from a user's local device to the FileVO server for storage.

**User**
An individual who has registered an account and uses FileVO to store, manage, and access files.

**User Interface (UI)**
The visual and interactive elements through which users interact with FileVO application.

**User Experience (UX)**
The overall experience a user has when using FileVO, encompassing usability, accessibility, and satisfaction.

---

### V

**Version Control / Version History**
A system that tracks changes and maintains historical versions of files. FileVO maintains version histories and modification records for files.

**Viewer**
A component or feature that displays file contents. FileVO includes viewers for PDFs, images, videos, audio, and text files.

---

### W

**Web Application**
A software application accessed through a web browser. FileVO supports web platforms alongside mobile and desktop applications.

**Windows**
Microsoft's desktop operating system, one of the supported platforms for FileVO.

**Workspace**
A collaborative space or environment. In FileVO, Rooms serve as workspaces for team collaboration.

---

### Additional Technical Terms

**Frontend-Backend Architecture**
The separation of the user interface (frontend) from the server-side logic (backend). FileVO uses Flutter for frontend and Node.js for backend.

**Cross-Platform**
The ability of software to run on multiple operating systems or platforms with minimal or no modifications. FileVO is a cross-platform solution.

**Localization (L10n)**
The process of adapting software for different languages and regions. FileVO supports localization for Arabic and English.

**State Management**
The management of application data and UI state. FileVO uses Provider for Flutter state management.

**HTTP Methods**
Standard operations for API communication: GET (retrieve), POST (create), PUT (update), DELETE (remove). Used throughout FileVO's RESTful API.
