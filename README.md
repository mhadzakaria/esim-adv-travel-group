# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

---

## Grape API

### Installation

1.  Install the required gems:

    ```bash
    bundle install
    ```

### Running the application

1.  Start the Rails server:

    ```bash
    rails server
    ```

### API Endpoints

#### Get eSIM Summary

*   **Endpoint:** `GET /api/v1/esim/summary`
*   **Description:** Retrieves the summary of an eSIM.
*   **Parameters:**
    *   `cid` (string, required): The customer ID.

*   **Example:**

    ```bash
    curl http://localhost:3000/api/v1/esim/summary?cid=C0001
    ```
