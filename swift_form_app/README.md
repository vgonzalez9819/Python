# SwiftUIFormApp

This is a small SwiftUI application that works on both iPad and Mac (using Catalyst). It functions like a simplified Google Form that stores submissions locally using SQLite.

## Features

- Cross‑platform (iOS/iPadOS and macOS Catalyst)
- Enter "Name" and "Asset Tag" information
- Submissions are stored in a local SQLite database
- View previously submitted entries in a list
- Admin login protected by local credentials (password stored as SHA256 hash)
- Edit or delete entries in the admin dashboard

### Default Admin Credentials

- Username: `admin`
- Password: `$uper@dmin` (stored hashed)

## Building

Open the project in Xcode 13 or later and run on iOS or macOS Catalyst. The code is organized in the `Sources/SwiftUIFormApp` directory and uses only SwiftUI and the built‑in SQLite3 library, so no external dependencies are required.
