# Operations Integration Flow - FileVO

## How Operations Are Connected and Integrated

This document explains how different operations in FileVO are connected and work together in an integrated flow.

---

## Overview: System Operation Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                    FileVO System Workflow                         │
└──────────────────────────────────────────────────────────────────┘

    [User Registration] → [Email Verification] → [Login]
           ↓                      ↓                  ↓
    [User Profile] ←──────────────────────────────────┘
           ↓
    [File Upload] → [File Processing] → [AI Embedding]
           ↓                  ↓                  ↓
    [Storage Check]    [Categorization]    [Database Save]
           ↓                  ↓                  ↓
    [File Organization] ← [File Metadata] ← [MongoDB]
           ↓
    [File Preview/Download/Edit]
           ↓
    [Search Operations] ← [Semantic Search]
           ↓
    [Sharing & Collaboration] → [Real-Time Notifications]
           ↓
    [Room Management] → [Member Invitations]
```

---

## Complete User Journey Flow

### Phase 1: Account Setup and Authentication

#### Step 1: Registration → Verification → Login
```
1. User Registration
   ├── Frontend: User enters email, password, name
   ├── Backend: Validate input → Hash password → Create user
   ├── MongoDB: Store user record (emailVerified: false)
   ├── Email Service: Send verification code
   └── Result: Account created, awaiting verification

2. Email Verification
   ├── User: Receives email with code
   ├── Frontend: User enters verification code
   ├── Backend: Verify code → Update user (emailVerified: true)
   └── Result: Account activated

3. Login
   ├── Frontend: User enters credentials
   ├── Backend: Verify password → Generate JWT token
   ├── Frontend: Store token (SharedPreferences)
   └── Result: User authenticated, token stored
```

**Connection**: Registration must complete before login. Email verification enables login.

---

### Phase 2: File Management Operations

#### Step 2: File Upload → Processing → Organization

```
1. File Upload Flow
   ├── Pre-Upload Check
   │   ├── Frontend: Check storage quota (GET /files/storage)
   │   ├── Backend: Query MongoDB → Calculate storage used
   │   ├── Frontend: Validate available space
   │   └── If insufficient → Block upload, show error
   │
   ├── Upload Process
   │   ├── Frontend: Select file(s) → Prepare upload
   │   ├── Frontend: Check dangerous files → Convert if needed
   │   ├── Frontend: POST /files/upload (file + metadata)
   │   ├── Backend: Validate file type → Virus scan
   │   ├── Backend: Save file to File Storage System
   │   └── Backend: Create file metadata in MongoDB
   │
   ├── Post-Upload Processing
   │   ├── Backend: Categorize file (Documents/Images/etc)
   │   ├── Backend: Update storage usage in MongoDB
   │   ├── Backend: Initiate background AI processing
   │   │   ├── Send file content to Hugging Face API
   │   │   ├── Receive embeddings
   │   │   └── Store embeddings in MongoDB
   │   └── Backend: Return success response
   │
   └── Frontend Update
       ├── Receive upload confirmation
       ├── Refresh storage info
       ├── Update file list UI
       └── Show success message
```

**Connection**: 
- Storage check must pass before upload
- Upload creates file record → triggers processing
- Processing enables future search operations

#### Step 3: File Organization → Folder Management

```
1. Folder Creation
   ├── User: Creates folder structure
   ├── Frontend: POST /folders (name, parentId)
   ├── Backend: Validate → Check duplicates → Generate unique name
   ├── MongoDB: Create folder record
   └── Frontend: Update folder tree

2. File Movement
   ├── User: Moves file to folder
   ├── Frontend: PUT /files/{fileId}/move (new parentFolderId)
   ├── Backend: Validate access → Update file.parentFolderId
   ├── MongoDB: Update file document
   └── Frontend: Refresh file list

3. File Organization Flow
   ├── Files uploaded to root or specific folder
   ├── Files can be moved between folders
   ├── Folders can be nested (parent-child hierarchy)
   ├── Categories work within folder context
   └── Storage statistics reflect folder structure
```

**Connection**:
- Files can be organized before/after upload
- Folder structure affects file listing and categorization
- Organization enables efficient file retrieval

---

### Phase 3: File Access and Operations

#### Step 4: File Search → Discovery → Access

```
1. Traditional Search (Name/Category)
   ├── User: Enters search query or selects category
   ├── Frontend: GET /files/search or /files/category/{category}
   ├── Backend: Query MongoDB (filter by name/category/parentFolder)
   ├── MongoDB: Return matching file metadata
   └── Frontend: Display search results

2. Semantic Search (AI-Powered)
   ├── User: Enters natural language query
   ├── Frontend: POST /ai/search (query text)
   ├── Backend: Generate query embedding via Hugging Face API
   ├── Backend: Retrieve file embeddings from MongoDB
   ├── Backend: Calculate similarity scores
   ├── Backend: Get top matching files from MongoDB
   └── Frontend: Display semantic search results

3. File Access Flow
   ├── User: Clicks on file from search results
   ├── Frontend: GET /files/{fileId}/view
   ├── Backend: Verify access → Get file metadata
   ├── Backend: Stream file from File Storage
   ├── Frontend: Determine file type → Open appropriate viewer
   └── User: Views/downloads/edits file
```

**Connection**:
- Upload processing creates embeddings → enables semantic search
- Search results link to file access operations
- Both search methods use same file metadata from MongoDB

---

### Phase 4: Collaboration and Sharing

#### Step 5: Room Creation → Sharing → Real-Time Updates

```
1. Room Creation
   ├── User: Creates room (name, description)
   ├── Frontend: POST /rooms (room details)
   ├── Backend: Create room in MongoDB (owner: current user)
   ├── MongoDB: Store room document
   └── Frontend: Navigate to room details

2. Member Invitation
   ├── Room Owner: Invites user by email
   ├── Frontend: POST /rooms/{roomId}/invite (email)
   ├── Backend: Create invitation in MongoDB
   ├── Email Service: Send invitation email
   ├── MongoDB: Store pending invitation
   └── Result: Invitation sent, awaiting acceptance

3. Invitation Acceptance
   ├── Invited User: Receives email → Opens app
   ├── Frontend: GET /rooms/invitations/pending
   ├── Backend: Return pending invitations
   ├── User: Accepts invitation
   ├── Frontend: POST /rooms/invitations/{id}/accept
   ├── Backend: Add member to room.members array
   └── MongoDB: Update room document

4. File Sharing in Room
   ├── Room Member: Shares file in room
   ├── Frontend: POST /rooms/{roomId}/share-file (fileId)
   ├── Backend: Validate access → Add file to room.files
   ├── MongoDB: Update room document
   ├── Socket.IO: Emit "fileShared" event to room members
   ├── Other Members: Receive real-time notification
   └── Frontend: Update UI to show new shared file

5. Real-Time Collaboration
   ├── User A: Shares file → Backend emits Socket.IO event
   ├── Socket.IO Server: Broadcasts to all connected room members
   ├── User B & C Frontends: Receive event via Socket.IO client
   ├── Frontends: Update UI automatically (no page refresh)
   └── Result: All members see updates instantly
```

**Connection**:
- Room creation enables collaboration space
- Invitations connect users to rooms
- File sharing connects file management to collaboration
- Real-time updates keep all members synchronized

---

## Cross-Operation Integration Flow

### Complete File Lifecycle

```
[File Upload]
    ↓
[File Processing]
    ├── → Categorization → Appears in category lists
    ├── → AI Embedding → Enables semantic search
    └── → Metadata Storage → Enables all file operations
         ↓
    [File Organization]
         ├── → Can move to folders
         └── → Can rename/modify
         ↓
    [File Access]
         ├── → Preview (PDF/Image/Video viewer)
         ├── → Download (to local device)
         ├── → Edit (text/image/video editor)
         └── → Update content (save changes)
         ↓
    [File Sharing]
         ├── → Share with individual users
         └── → Share in rooms (collaboration)
         ↓
    [Real-Time Updates]
         └── → Notifications to collaborators
         ↓
    [File Deletion]
         ├── → Soft delete (move to trash)
         ├── → Restoration (from trash)
         └── → Permanent deletion
```

---

## Integrated Operation Sequences

### Scenario 1: New User → Upload → Share → Collaborate

```
Step 1: User Registration & Login
   Registration → Email Verification → Login → Token Stored
   
Step 2: Initial File Upload
   Check Storage → Upload File → Processing → Categorization → AI Embedding
   
Step 3: File Organization
   Create Folder → Move File to Folder → Update Metadata
   
Step 4: Create Collaboration Room
   Create Room → Invite Member → Member Accepts → Both Connected
   
Step 5: Share File in Room
   Share File → Backend Updates Room → Socket.IO Broadcast → Member Receives
   
Step 6: Real-Time Collaboration
   Member Opens File → Member Comments → Real-Time Update → Owner Sees Comment
```

### Scenario 2: File Search → Access → Edit → Update

```
Step 1: Semantic Search
   Enter Query → Generate Embedding → Compare with Files → Get Results
   
Step 2: File Access
   Select File → Backend Verifies Access → Stream File → Open Viewer
   
Step 3: File Editing
   Open Editor → Modify Content → Save Changes → Backend Updates
   
Step 4: Background Processing (if needed)
   File Updated → Regenerate AI Embedding → Update MongoDB
   
Step 5: Real-Time Notification (if shared)
   File Updated → Socket.IO Event → Collaborators Notified
```

### Scenario 3: Storage Management Flow

```
Step 1: Storage Monitoring
   User Views Storage Page → Frontend Requests Storage Info
   
Step 2: Storage Calculation
   Backend Queries MongoDB → Aggregates File Sizes → Returns Statistics
   
Step 3: Storage Visualization
   Frontend Displays: Used/Total, Category Breakdown, Charts
   
Step 4: Storage Actions
   User Identifies Large Files → Deletes Files → Storage Freed
   
Step 5: Storage Update
   File Deleted → Backend Updates Storage Count → Frontend Refreshes
```

---

## Real-Time Integration Flow

### Socket.IO Event Flow

```
User Action → Backend API → MongoDB Update → Socket.IO Emit → Other Clients

Example: File Shared in Room
1. User A: Share file → POST /rooms/{roomId}/share-file
2. Backend: Update MongoDB room.files array
3. Backend: Emit Socket.IO event "fileShared" to room
4. Socket.IO Server: Broadcast to User B, C, D (all room members)
5. User B's Frontend: Receives event → Updates UI → Shows new file
6. User C's Frontend: Receives event → Updates UI → Shows new file
```

**Event Types and Flow**:
- **fileShared**: File added to room → All members notified
- **fileUpdated**: File modified → Collaborators notified
- **memberAdded**: New member joins room → Existing members notified
- **commentAdded**: Comment on file → Room members notified

---

## Data Flow Between Components

### File Upload to Search Integration

```
1. File Upload
   File → Backend → Storage System (physical file)
   Metadata → Backend → MongoDB (file record)
   
2. Background Processing
   File Content → Backend → Hugging Face API (embeddings)
   Embeddings → Backend → MongoDB (file.embedding field)
   
3. Search Operation
   Query → Frontend → Backend → Hugging Face API (query embedding)
   Query Embedding + File Embeddings → Backend (similarity calculation)
   Top Matches → Backend → MongoDB (file metadata retrieval)
   Results → Backend → Frontend (display)
```

### Storage Quota Management Integration

```
1. Upload Request
   User Uploads File → Frontend Checks Storage → Backend Validates
   
2. Storage Calculation
   Backend → MongoDB Aggregation → Sum all user file sizes
   
3. Quota Check
   Compare: storageUsed + newFileSize vs storageLimit
   
4. Decision
   If OK → Proceed Upload → Update storageUsed
   If Exceeded → Reject Upload → Show Error
   
5. Storage Update
   File Uploaded → Backend Updates user.storageUsed in MongoDB
   Storage Info Refreshed → Frontend Updates UI
```

---

## Authentication Flow Through All Operations

### Token-Based Authentication Pattern

```
1. Login
   Credentials → Backend → Verify → Generate JWT Token → Frontend Storage
   
2. All Subsequent Operations
   Frontend Request → Include Token in Header → Backend Verify Token
   If Valid → Process Request → Return Response
   If Invalid → Return 401 → Frontend Redirects to Login
   
3. Token Usage
   Every API Request: Authorization: Bearer {token}
   Protected Routes: Backend middleware verifies token
   Real-Time: Token included in Socket.IO auth
```

**Integration**: Authentication token enables all operations. Without valid token, most operations are blocked.

---

## Error Handling and Recovery Flow

### Operation Failure Handling

```
1. Operation Attempt
   User Action → Frontend Request → Backend Processing
   
2. Error Detection
   Validation Error → Backend returns 400 (Bad Request)
   Authentication Error → Backend returns 401 (Unauthorized)
   Not Found → Backend returns 404 (Not Found)
   Server Error → Backend returns 500 (Internal Error)
   
3. Frontend Error Handling
   Receive Error Response → Parse Error Message → Display to User
   Network Error → Retry Logic → Show Connection Error
   
4. User Recovery
   User Sees Error → Corrects Input/Retries → Operation Success
```

---

## Summary: How Operations Connect

### Key Integration Points

1. **Authentication Chain**
   - Registration → Verification → Login → All Operations

2. **File Management Chain**
   - Upload → Processing → Organization → Access → Share → Delete

3. **Search Chain**
   - Upload → AI Processing → Embedding Storage → Semantic Search → File Access

4. **Collaboration Chain**
   - Room Creation → Invitations → Member Join → File Sharing → Real-Time Updates

5. **Storage Chain**
   - Upload → Storage Check → Usage Update → Quota Enforcement → Storage Display

6. **Real-Time Chain**
   - Any Operation → Backend Update → MongoDB Save → Socket.IO Broadcast → Client Updates

### Cross-Operation Dependencies

- **Search depends on Upload**: Files must be uploaded and processed before they appear in search
- **Sharing depends on Files**: Files must exist before they can be shared
- **Real-Time depends on Collaboration**: Rooms must exist for real-time collaboration
- **All operations depend on Authentication**: User must be logged in for most operations
- **AI Search depends on Processing**: Files need embeddings generated after upload

---

This integration flow shows how FileVO operations are interconnected, creating a cohesive file management and collaboration system where each operation builds upon or enables other operations.
