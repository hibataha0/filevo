# Sequence Diagrams - FileVO

## Sequence Diagrams

This document contains detailed sequence diagrams illustrating the interactions between different components of the FileVO system for key operations.

---

## 1. User Registration and Email Verification Sequence Diagram

```
┌─────────┐     ┌─────────┐     ┌─────────────┐     ┌──────────────┐
│  User   │     │ Frontend│     │   Backend   │     │ Email Service│
│         │     │  (App)  │     │   (API)     │     │   (SMTP)     │
└────┬────┘     └────┬────┘     └──────┬──────┘     └──────┬───────┘
     │                │                 │                    │
     │  1. Fill Registration Form      │                    │
     │─────────────────────────────────>│                    │
     │                │                 │                    │
     │                │  2. POST /auth/register              │
     │                │  (email, password, name)             │
     │                │─────────────────────────────────────>│
     │                │                 │                    │
     │                │                 │  3. Validate Input │
     │                │                 │  4. Hash Password  │
     │                │                 │  5. Create User    │
     │                │                 │  6. Generate Code  │
     │                │                 │                    │
     │                │                 │  7. Send Email     │
     │                │                 │  (verification)    │
     │                │                 │───────────────────>│
     │                │                 │                    │
     │                │  8. Response:   │                    │
     │                │  Success + User ID                   │
     │                │<─────────────────────────────────────│
     │                │                 │                    │
     │  9. Show Email Sent Message      │                    │
     │<─────────────────────────────────│                    │
     │                │                 │                    │
     │  10. Enter Verification Code     │                    │
     │──────────────────────────────────>│                    │
     │                │                 │                    │
     │                │  11. POST /auth/verifyEmail          │
     │                │  (email, code)                       │
     │                │─────────────────────────────────────>│
     │                │                 │                    │
     │                │                 │  12. Verify Code   │
     │                │                 │  13. Activate User │
     │                │                 │                    │
     │                │  14. Response:  │                    │
     │                │  Account Activated                   │
     │                │<─────────────────────────────────────│
     │                │                 │                    │
     │  15. Show Success Message        │                    │
     │<─────────────────────────────────│                    │
     │                │                 │                    │
```

**Description**: 
1. User enters registration details in the app
2. Frontend sends registration request to backend
3. Backend validates input, hashes password, creates user record
4. Backend generates verification code and stores it
5. Backend sends verification email via SMTP service
6. Backend responds with success
7. User receives email and enters verification code
8. Frontend sends verification code to backend
9. Backend verifies code and activates user account
10. User sees success message and can now login

---

## 2. User Login Sequence Diagram

```
┌─────────┐     ┌─────────┐     ┌─────────────┐     ┌──────────────┐
│  User   │     │ Frontend│     │   Backend   │     │   MongoDB    │
│         │     │  (App)  │     │   (API)     │     │  (Database)  │
└────┬────┘     └────┬────┘     └──────┬──────┘     └──────┬───────┘
     │                │                 │                    │
     │  1. Enter Credentials           │                    │
     │─────────────────────────────────>│                    │
     │                │                 │                    │
     │                │  2. POST /auth/login                 │
     │                │  (email, password)                   │
     │                │─────────────────────────────────────>│
     │                │                 │                    │
     │                │                 │  3. Find User      │
     │                │                 │  by Email          │
     │                │                 │───────────────────>│
     │                │                 │                    │
     │                │                 │  4. User Data      │
     │                │                 │<───────────────────│
     │                │                 │                    │
     │                │                 │  5. Verify Password│
     │                │                 │  (Bcrypt Compare)  │
     │                │                 │                    │
     │                │                 │  6. Generate JWT   │
     │                │                 │  Token             │
     │                │                 │                    │
     │                │  7. Response:   │                    │
     │                │  Success + Token + User Data         │
     │                │<─────────────────────────────────────│
     │                │                 │                    │
     │                │  8. Store Token │                    │
     │                │  (SharedPreferences)                 │
     │                │                 │                    │
     │  9. Navigate to Home            │                    │
     │<─────────────────────────────────│                    │
     │                │                 │                    │
```

**Description**:
1. User enters email and password
2. Frontend sends login request to backend
3. Backend queries database to find user by email
4. Database returns user data
5. Backend verifies password using Bcrypt
6. Backend generates JWT token upon successful verification
7. Backend returns token and user data to frontend
8. Frontend stores token securely in local storage
9. User is redirected to home screen

---

## 3. File Upload Sequence Diagram

```
┌─────────┐  ┌─────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐
│  User   │  │ Frontend│  │   Backend   │  │   MongoDB    │  │File Storage │
│         │  │  (App)  │  │   (API)     │  │  (Database)  │  │   (Server)  │
└────┬────┘  └────┬────┘  └──────┬──────┘  └──────┬───────┘  └──────┬──────┘
     │             │              │                 │                  │
     │ 1. Select File             │                 │                  │
     │────────────>│              │                 │                  │
     │             │              │                 │                  │
     │             │ 2. Check Storage Quota         │                  │
     │             │    GET /files/storage          │                  │
     │             │───────────────────────────────>│                  │
     │             │              │                 │                  │
     │             │              │ 3. Get User     │                  │
     │             │              │    Storage Info │                  │
     │             │              │─────────────────>│                 │
     │             │              │                 │                  │
     │             │              │ 4. Storage Data │                  │
     │             │              │<─────────────────│                 │
     │             │              │                 │                  │
     │             │ 5. Storage Info                │                  │
     │             │<───────────────────────────────│                  │
     │             │              │                 │                  │
     │             │ 6. Validate Quota              │                  │
     │             │    (Check if enough space)     │                  │
     │             │              │                 │                  │
     │             │ 7. POST /files/upload          │                  │
     │             │    (file data + metadata)      │                  │
     │             │───────────────────────────────>│                  │
     │             │              │                 │                  │
     │             │              │ 8. Validate     │                  │
     │             │              │    File Type    │                  │
     │             │              │ 9. Virus Scan   │                  │
     │             │              │                 │                  │
     │             │              │ 10. Save File   │                  │
     │             │              │     to Storage  │                  │
     │             │              │──────────────────────────────────>│
     │             │              │                 │                  │
     │             │              │ 11. File Saved  │                  │
     │             │              │<──────────────────────────────────│
     │             │              │                 │                  │
     │             │              │ 12. Categorize  │                  │
     │             │              │     File        │                  │
     │             │              │ 13. Create File │                  │
     │             │              │     Metadata    │                  │
     │             │              │─────────────────>│                 │
     │             │              │                 │                  │
     │             │              │ 14. File Record │                  │
     │             │              │     Created     │                  │
     │             │              │<─────────────────│                 │
     │             │              │                 │                  │
     │             │              │ 15. Initiate    │                  │
     │             │              │     Background  │                  │
     │             │              │     Processing  │                  │
     │             │              │     (AI Embedding)                 │
     │             │              │                 │                  │
     │             │ 16. Response:                  │                  │
     │             │     File Uploaded Successfully │                  │
     │             │<───────────────────────────────│                  │
     │             │              │                 │                  │
     │ 17. Show Success            │                 │                  │
     │<────────────────────────────│                 │                  │
     │             │              │                 │                  │
```

**Description**:
1. User selects file(s) from device
2. Frontend checks user's storage quota
3-5. Backend returns current storage usage
6. Frontend validates available space
7. Frontend sends file with metadata to backend
8-9. Backend validates file type and scans for viruses
10-11. Backend saves file to server storage
12-14. Backend categorizes file and creates database record
15. Backend initiates background processing (AI embedding generation)
16-17. Backend responds with success, frontend displays confirmation

---

## 4. File Download Sequence Diagram

```
┌─────────┐  ┌─────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐
│  User   │  │ Frontend│  │   Backend   │  │   MongoDB    │  │File Storage │
│         │  │  (App)  │  │   (API)     │  │  (Database)  │  │   (Server)  │
└────┬────┘  └────┬────┘  └──────┬──────┘  └──────┬───────┘  └──────┬──────┘
     │             │              │                 │                  │
     │ 1. Select File to Download│                 │                  │
     │────────────>│              │                 │                  │
     │             │              │                 │                  │
     │             │ 2. GET /files/{fileId}/download                    │
     │             │───────────────────────────────>│                  │
     │             │              │                 │                  │
     │             │              │ 3. Verify       │                  │
     │             │              │    User Access  │                  │
     │             │              │ 4. Get File     │                  │
     │             │              │    Metadata     │                  │
     │             │              │─────────────────>│                 │
     │             │              │                 │                  │
     │             │              │ 5. File Metadata│                  │
     │             │              │<─────────────────│                 │
     │             │              │                 │                  │
     │             │              │ 6. Read File    │                  │
     │             │              │    from Storage │                  │
     │             │              │──────────────────────────────────>│
     │             │              │                 │                  │
     │             │              │ 7. File Stream  │                  │
     │             │              │<──────────────────────────────────│
     │             │              │                 │                  │
     │             │ 8. Download Stream             │                  │
     │             │    (with progress updates)     │                  │
     │             │<───────────────────────────────│                  │
     │             │              │                 │                  │
     │             │ 9. Save File to Device         │                  │
     │             │    (Local Storage)             │                  │
     │             │              │                 │                  │
     │ 10. File Downloaded        │                 │                  │
     │<───────────────────────────│                 │                  │
     │             │              │                 │                  │
```

**Description**:
1. User selects file to download
2. Frontend sends download request with file ID
3-5. Backend verifies user access and retrieves file metadata from database
6-7. Backend reads file from storage system
8. Backend streams file data to frontend with progress updates
9. Frontend saves file to device storage
10. User receives downloaded file

---

## 5. Semantic Search Sequence Diagram

```
┌─────────┐  ┌─────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐
│  User   │  │ Frontend│  │   Backend   │  │   MongoDB    │  │  Hugging    │
│         │  │  (App)  │  │   (API)     │  │  (Database)  │  │Face API     │
└────┬────┘  └────┬────┘  └──────┬──────┘  └──────┬───────┘  └──────┬──────┘
     │             │              │                 │                  │
     │ 1. Enter Search Query      │                 │                  │
     │────────────>│              │                 │                  │
     │             │              │                 │                  │
     │             │ 2. POST /ai/search             │                  │
     │             │    (query text)                │                  │
     │             │───────────────────────────────>│                  │
     │             │              │                 │                  │
     │             │              │ 3. Generate     │                  │
     │             │              │    Query        │                  │
     │             │              │    Embedding    │                  │
     │             │              │──────────────────────────────────>│
     │             │              │                 │                  │
     │             │              │ 4. Query Embedding                │
     │             │              │<──────────────────────────────────│
     │             │              │                 │                  │
     │             │              │ 5. Get File     │                  │
     │             │              │    Embeddings   │                  │
     │             │              │    from DB      │                  │
     │             │              │─────────────────>│                 │
     │             │              │                 │                  │
     │             │              │ 6. File Embeddings                │
     │             │              │<─────────────────│                 │
     │             │              │                 │                  │
     │             │              │ 7. Calculate    │                  │
     │             │              │    Similarity   │                  │
     │             │              │    Scores       │                  │
     │             │              │                 │                  │
     │             │              │ 8. Get File     │                  │
     │             │              │    Details      │                  │
     │             │              │    (Top Matches)│                  │
     │             │              │─────────────────>│                 │
     │             │              │                 │                  │
     │             │              │ 9. File Metadata│                  │
     │             │              │<─────────────────│                 │
     │             │              │                 │                  │
     │             │ 10. Response:                  │                  │
     │             │     Search Results             │                  │
     │             │<───────────────────────────────│                  │
     │             │              │                 │                  │
     │ 11. Display Search Results │                 │                  │
     │<───────────────────────────│                 │                  │
     │             │              │                 │                  │
```

**Description**:
1. User enters search query (natural language)
2. Frontend sends search request to backend
3-4. Backend sends query to Hugging Face API to generate embedding
5-6. Backend retrieves file embeddings from database
7. Backend calculates similarity scores between query and file embeddings
8-9. Backend retrieves metadata for top matching files
10-11. Backend returns search results, frontend displays them

---

## 6. Real-Time File Sharing in Room Sequence Diagram

```
┌─────────┐  ┌─────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐
│  User A │  │Frontend │  │   Backend   │  │   MongoDB    │  │ Socket.IO   │
│         │  │  (App)  │  │   (API)     │  │  (Database)  │  │  Server     │
└────┬────┘  └────┬────┘  └──────┬──────┘  └──────┬───────┘  └──────┬──────┘
     │             │              │                 │                  │
     │ 1. Share File in Room     │                 │                  │
     │────────────>│              │                 │                  │
     │             │              │                 │                  │
     │             │ 2. POST /rooms/{roomId}/share-file                │
     │             │    (fileId)                    │                  │
     │             │───────────────────────────────>│                  │
     │             │              │                 │                  │
     │             │              │ 3. Verify       │                  │
     │             │              │    Room Access  │                  │
     │             │              │ 4. Add File to  │                  │
     │             │              │    Room         │                  │
     │             │              │─────────────────>│                 │
     │             │              │                 │                  │
     │             │              │ 5. Room Updated │                  │
     │             │              │<─────────────────│                 │
     │             │              │                 │                  │
     │             │              │ 6. Emit Socket  │                  │
     │             │              │    Event        │                  │
     │             │              │    "fileShared" │                  │
     │             │              │──────────────────────────────────>│
     │             │              │                 │                  │
     │             │              │                 │ 7. Broadcast     │
     │             │              │                 │    to Room Members│
     │             │              │                 │                  │
     │             │              │                 │ 8. Emit to       │
     │             │              │                 │    User B & C    │
     │             │              │                 │<──────────────────│
     │             │              │                 │                  │
     │             │              │ 9. Response:    │                  │
     │             │              │     File Shared │                  │
     │             │              │<──────────────────────────────────│
     │             │              │                 │                  │
     │             │ 10. Success Response           │                  │
     │             │<───────────────────────────────│                  │
     │             │              │                 │                  │
     │             │              │                 │ 11. Socket Event │
     │             │              │                 │    (to User B)   │
     ┌─────────┐   │              │                 │──────────────────>│
     │User B   │   │              │                 │                  │
     │Frontend │   │              │                 │                  │
     └────┬────┘   │              │                 │                  │
          │        │              │                 │                  │
          │ 12. Receive Real-Time│                 │                  │
          │      Notification    │                 │                  │
          │<──────────────────────────────────────────────────────────│
          │        │              │                 │                  │
          │ 13. Update UI        │                 │                  │
          │      (Show New File) │                 │                  │
          │        │              │                 │                  │
```

**Description**:
1. User A shares a file in a room
2. Frontend sends share request to backend
3-5. Backend verifies access and updates room in database
6. Backend emits Socket.IO event to all room members
7-8. Socket.IO server broadcasts event to all connected clients in the room
9-10. Backend confirms to User A
11-13. User B's frontend receives real-time notification and updates UI

---

## 7. Folder Creation Sequence Diagram

```
┌─────────┐  ┌─────────┐  ┌─────────────┐  ┌──────────────┐
│  User   │  │ Frontend│  │   Backend   │  │   MongoDB    │
│         │  │  (App)  │  │   (API)     │  │  (Database)  │
└────┬────┘  └────┬────┘  └──────┬──────┘  └──────┬───────┘
     │             │              │                 │
     │ 1. Click Create Folder    │                 │
     │────────────>│              │                 │
     │             │              │                 │
     │             │              │                 │
     │ 2. Enter Folder Name      │                 │
     │────────────>│              │                 │
     │             │              │                 │
     │             │ 3. POST /folders               │
     │             │    (name, parentId)            │
     │             │───────────────────────────────>│
     │             │              │                 │
     │             │              │ 4. Validate     │
     │             │              │    Input        │
     │             │              │ 5. Check for    │
     │             │              │    Duplicate    │
     │             │              │    Name         │
     │             │              │─────────────────>│
     │             │              │                 │
     │             │              │ 6. Check Result │
     │             │              │<─────────────────│
     │             │              │                 │
     │             │              │ 7. Generate     │
     │             │              │    Unique Name  │
     │             │              │    (if needed)  │
     │             │              │                 │
     │             │              │ 8. Create Folder│
     │             │              │    Record       │
     │             │              │─────────────────>│
     │             │              │                 │
     │             │              │ 9. Folder       │
     │             │              │    Created      │
     │             │              │<─────────────────│
     │             │              │                 │
     │             │ 10. Response:                  │
     │             │     Folder Created             │
     │             │<───────────────────────────────│
     │             │              │                 │
     │ 11. Show Folder in List   │                 │
     │<───────────────────────────│                 │
     │             │              │                 │
```

**Description**:
1. User initiates folder creation
2. User enters folder name
3. Frontend sends folder creation request
4-6. Backend validates input and checks for duplicate names
7. Backend generates unique name if duplicate exists
8-9. Backend creates folder record in database
10-11. Backend responds with success, frontend updates UI

---

## 8. File Preview Sequence Diagram

```
┌─────────┐  ┌─────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐
│  User   │  │ Frontend│  │   Backend   │  │   MongoDB    │  │File Storage │
│         │  │  (App)  │  │   (API)     │  │  (Database)  │  │   (Server)  │
└────┬────┘  └────┬────┘  └──────┬──────┘  └──────┬───────┘  └──────┬──────┘
     │             │              │                 │                  │
     │ 1. Click on File          │                 │                  │
     │────────────>│              │                 │                  │
     │             │              │                 │                  │
     │             │ 2. GET /files/{fileId}/view    │                  │
     │             │───────────────────────────────>│                  │
     │             │              │                 │                  │
     │             │              │ 3. Verify       │                  │
     │             │              │    Access       │                  │
     │             │              │ 4. Get File     │                  │
     │             │              │    Metadata     │                  │
     │             │              │─────────────────>│                 │
     │             │              │                 │                  │
     │             │              │ 5. File Metadata│                  │
     │             │              │<─────────────────│                 │
     │             │              │                 │                  │
     │             │              │ 6. Check File   │                  │
     │             │              │    Type         │                  │
     │             │              │                 │                  │
     │             │              │ 7. Stream File  │                  │
     │             │              │    Content      │                  │
     │             │              │──────────────────────────────────>│
     │             │              │                 │                  │
     │             │              │ 8. File Stream  │                  │
     │             │              │<──────────────────────────────────│
     │             │              │                 │                  │
     │             │ 9. File Data Stream            │                  │
     │             │<───────────────────────────────│                  │
     │             │              │                 │                  │
     │             │ 10. Determine Viewer           │                  │
     │             │     (PDF/Image/Video/etc)      │                  │
     │             │                                │                  │
     │ 11. Open Appropriate Viewer│                 │                  │
     │     (PDF Viewer, Image Viewer, etc)          │                  │
     │<─────────────────────────────────────────────│                 │
     │             │              │                 │                  │
```

**Description**:
1. User clicks on file to preview
2. Frontend requests file view from backend
3-5. Backend verifies access and retrieves file metadata
6. Backend determines file type
7-8. Backend streams file content from storage
9-10. Frontend receives file stream and determines viewer type
11. Frontend opens appropriate viewer (PDF, Image, Video, etc.)

---

## Notes on Sequence Diagrams

### Common Patterns

1. **Authentication**: Most operations require JWT token in request headers (not shown in all diagrams for clarity)
2. **Error Handling**: Each step may fail; error responses are handled by frontend
3. **Loading States**: Frontend shows loading indicators during async operations
4. **Token Refresh**: Long-running operations may require token refresh (not shown)

### Key Components Interaction

- **Frontend ↔ Backend**: RESTful API communication (HTTP/HTTPS)
- **Backend ↔ Database**: MongoDB queries and operations
- **Backend ↔ External Services**: HTTP requests to Hugging Face, SMTP
- **Frontend ↔ Backend**: Socket.IO for real-time updates (WebSocket)

### Real-Time Updates

Socket.IO events are bidirectional:
- Backend emits events to specific rooms/users
- Frontend listens for events and updates UI accordingly
- Connection is maintained throughout user session

---

These sequence diagrams provide detailed insight into how different components of FileVO interact to accomplish key operations, helping developers and stakeholders understand the system's behavior and data flow.
