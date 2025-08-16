This repository contains two applications: a Laravel API backend and an Angular frontend.

### Quick Overview of Default Ports

- **Backend (Local):** `http://127.0.0.1:8000`
- **Frontend (Local):** `http://127.0.0.1:4200`
- **Docker Backend:** `http://localhost:8000`
- **Docker Frontend:** `http://localhost:4200`

---

### Clone the Repository

```sh
git clone https://github.com/mrcashcash/smarti.git
cd smarti
```

---

### Automated Setup (Experimental)

For a quicker setup, you can use the provided scripts to automate the installation and running of the development environment. These scripts are not fully tested and may require adjustments based on your system configuration.

#### On Windows

```sh
.\Scripts\run_local.bat
```

#### On macOS/Linux

```sh
chmod +x Scripts/run_local.sh
./Scripts/run_local.sh
```

---

### Manual Setup

You will need two separate terminals for the manual setup.

#### Backend (Laravel)

1.  **Navigate to the backend directory:**
    ```sh
    cd smarti-backend
    ```
2.  **Set up the environment file:**
    ```sh
    cp .env.example .env
    ```
3.  **Install dependencies:**
    ```sh
    composer install
    ```
4.  **Generate an application key:**
    ```sh
    php artisan key:generate
    ```
5.  **Configure your database** in the `.env` file. For a quick start with the included demo database, use:
    ```
    DB_CONNECTION=sqlite
    DB_DATABASE=database/database.sqlite
    ```
6.  **Run database migrations (Not really Needed- Demo DB exist):**
    ```sh
    php artisan migrate
    ```
7.  **Start the server:**
    ```sh
    php artisan serve
    ```

#### Frontend (Angular)

1.  **Navigate to the frontend directory:**
    ```sh
    cd smarti-frontend
    ```
2.  **Install dependencies:**
    ```sh
    npm install
    ```
3.  **Start the development server:**
    ```sh
    npm start
    ```
    The frontend will connect to the backend at `http://127.0.0.1:8000/api` by default.

---

### Running with Docker

From the root directory of the project:

1.  **Build and start the services:**

    ```sh
    docker-compose up --build
    ```

    To run in the background, add the `-d` flag.

2.  **Stop and remove the containers:**
    ```sh
    docker-compose down
    ```

---
