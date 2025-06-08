# CSV Manager 

A modern web app for uploading, managing, and editing CSV files, built with Wasp, React, and Tailwind CSS.

---

## Features

- Upload CSV files with step-by-step import flow
- Map CSV columns to system fields
- View, sort, filter, and edit CSV data in a table
- Delete CSV files with confirmation dialog
- Responsive, accessible UI using shadcn/ui and Tailwind CSS

---

## Demo Of Csv Manager

[![Demo Video](https://drive.google.com/file/d/1-WLUNm2ekAM6ZIXeJ79qj0Sr0wAmcPoP/view?usp=sharing)

---

## Setup Instructions

1. **Clone the repository**
   ```sh
   git clone https://github.com/saloni-FED/csv-manager.git
   cd csv-manager/app
   ```

2. **Install dependencies**
   ```sh
   npm install
   ```

3. **Configure environment**
   - Copy `.env.example` to `.env` and fill in any required values.

4. **Run the app**
   ```sh
   wasp start
   ```

---

## Technical Approach

### Key Architectural Decisions
- Check Technical_Approach.md for Documentation
- **Wasp Framework**: Chosen for its full-stack capabilities and rapid prototyping with React, Prisma, and Node.js.
- **Component Structure**: The app uses a stepper pattern for CSV import, with each step as a separate React component for clarity and reusability.
- **State Management**: React hooks (`useState`, `useEffect`) manage local state, while Wasp actions/queries handle server communication and data fetching.
- **UI/UX**: shadcn/ui and Tailwind CSS provide a modern, accessible, and responsive interface. Dialogs are used for confirmations and modals.


### Challenges & Solutions

- **Large File Uploads**: Handled by using file upload actions and server-side parsing, with client-side validation for file size/type.
- **Data Table Performance**: Pagination and lazy loading are used for large CSVs to keep the UI responsive.
- **Security**: All file operations are scoped to the authenticated user, and server-side validation is performed on uploads and edits.

### Libraries/Tools Chosen

- **Wasp**: For full-stack app structure and rapid development.
- **React**: For UI components and state management.
- **Tailwind CSS**: For utility-first, responsive styling.
- **shadcn/ui**: For accessible, modern UI primitives (dialogs, buttons, etc.).
- **Papaparse**: For robust CSV parsing on the client.

---

## AI Chat History

See cursor_chat_history.md for a complete export of the AI interactions during development.

---

## Environment Variables

See `.env.example` for required environment variables.

---

## License

MIT
