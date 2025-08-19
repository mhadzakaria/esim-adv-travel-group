# Esim

This is a Ruby on Rails application for managing Esims.

## Getting Started

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd esim-adv-travel-group
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    ```

3.  **Set up the database:**
    ```bash
    rails db:migrate
    ```
    (If you need seed data, you might also run `rails db:seed`)

### Running the Application

1.  **Start the Rails server:**
    ```bash
    rails server
    ```
    The application will typically run on `http://localhost:3000`.

### Running Tests

To run the test suite:

```bash
rails test
```

## API Endpoints

The application exposes a Grape API.

### Get eSIM Summary

*   **Endpoint:** `GET /api/v1/esim/summary`
*   **Description:** Retrieves the summary of an eSIM.
*   **Parameters:**
    *   `cid` (string, required): The customer ID.

*   **Example:**

    ```bash
    curl http://localhost:3000/api/v1/esim/summary?cid=C0001
    ```