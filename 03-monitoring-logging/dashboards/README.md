# Grafana Dashboards

This directory contains the exported Grafana dashboards used in **Project 03 – Monitoring & Logging**. These dashboards provide visibility into system performance, application behavior, and centralized logging.

## 📊 Available Dashboards

* **system-metrics.json** → Based on [Grafana.com Dashboard 1860 – Node Exporter Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full/).

  * Tracks **node-level metrics** (CPU, memory, disk I/O, filesystem, and network usage) collected from **Node Exporter**.

* **app-metrics.json** → **Custom dashboard** for monitoring our **Flask application metrics**.

  * Visualizes counters and metrics exposed at the `/metrics` endpoint (e.g., `http_requests_total`).
  * Useful for tracking **request traffic, status codes, and app health**.
  * ⚠️ This dashboard is not available on Grafana.com and only exists as a JSON file in this repo.

* **logging-dashboard.json** → **Custom Splunk logging dashboard**.

  * Displays Flask app logs and Kubernetes logs ingested via Splunk.
  * Provides search panels, error trends, and log-based insights.

## 🚀 How to Import a Dashboard

1. Log in to **Grafana UI**.
2. Navigate to: **Dashboards → Import**.
3. Choose one of the following import options:

   * **Upload JSON file** → Select one of the `.json` files from this directory.
   * **Paste JSON** → Copy and paste the file contents directly.
4. Select the appropriate data source:

   * **Prometheus** → For `system-metrics.json` and `app-metrics.json`.
   * **Splunk** → For `logging-dashboard.json`.
5. Click **Import** → Dashboard will be available in Grafana.

## 📷 Screenshots

Screenshots of selected dashboards are stored under the [`screenshots/`](../screenshots/) directory for portfolio presentation.

* `system-metrics.json` → exported screenshot available.
* `logging-dashboard.json` → exported screenshot available.
* `app-metrics.json` → **custom only, no screenshot included**.

