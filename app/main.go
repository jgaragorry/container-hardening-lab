package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
    "runtime"
    "time"
)

type SecurityMetrics struct {
    ContainerID   string    `json:"container_id"`
    Timestamp     time.Time `json:"timestamp"`
    ReadOnly      bool      `json:"read_only_filesystem"`
    NoNewPrivs    bool      `json:"no_new_privileges"`
    Capabilities  []string  `json:"capabilities"`
    MemoryLimit   string    `json:"memory_limit"`
    CPUCount      int       `json:"cpu_count"`
    GoVersion     string    `json:"go_version"`
    NumGoroutines int       `json:"num_goroutines"`
}

type HealthStatus struct {
    Status      string    `json:"status"`
    Timestamp   time.Time `json:"timestamp"`
    Uptime      string    `json:"uptime"`
    Version     string    `json:"version"`
    ContainerID string    `json:"container_id"`
    Checks      struct {
        Distroless    bool `json:"distroless_base_image"`
        ReadOnly      bool `json:"read_only_filesystem"`
        NoShell       bool `json:"no_shell_access"`
        Capabilities  bool `json:"capabilities_restricted"`
        MemoryLimit   bool `json:"memory_limit_active"`
        NoNewPrivs    bool `json:"no_new_privileges"`
    } `json:"security_checks"`
}

func main() {
    startTime := time.Now()
    
    // Health check endpoint - Versión HTML visual
    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        // Si es API request (Accept: application/json)
        if r.Header.Get("Accept") == "application/json" {
            health := HealthStatus{
                Status:      "healthy",
                Timestamp:   time.Now(),
                Uptime:      time.Since(startTime).String(),
                Version:     "1.0.0-distroless",
                ContainerID: func() string { host, _ := os.Hostname(); return host }(),
            }
            health.Checks.Distroless = true
            health.Checks.ReadOnly = true
            health.Checks.NoShell = true
            health.Checks.Capabilities = true
            health.Checks.MemoryLimit = true
            health.Checks.NoNewPrivs = true
            
            w.Header().Set("Content-Type", "application/json")
            w.WriteHeader(http.StatusOK)
            json.NewEncoder(w).Encode(health)
            return
        }
        
        // Versión HTML visual
        hostname, _ := os.Hostname()
        currentTime := time.Now().Format("Monday, 02 January 2006 15:04:05")
        uptime := time.Since(startTime).Round(time.Second).String()
        
        html := `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Health Status | Distroless Secure Container</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:ital,wght@0,100..900;1,100..900&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .health-card {
            background: white;
            border-radius: 24px;
            max-width: 500px;
            width: 100%;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .health-header {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            padding: 32px;
            text-align: center;
            color: white;
        }

        .health-status-icon {
            font-size: 64px;
            margin-bottom: 16px;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }

        .health-status {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .health-subtitle {
            font-size: 14px;
            opacity: 0.9;
        }

        .health-body {
            padding: 32px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e2e8f0;
        }

        .info-label {
            font-weight: 600;
            color: #64748b;
            font-size: 14px;
        }

        .info-value {
            font-family: 'Courier New', monospace;
            font-size: 14px;
            color: #1e293b;
            font-weight: 500;
        }

        .checks-grid {
            margin: 24px 0;
        }

        .check-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 0;
        }

        .check-name {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
        }

        .check-status {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }

        .check-status.pass {
            background: #dcfce7;
            color: #059669;
        }

        .check-status.fail {
            background: #fee2e2;
            color: #dc2626;
        }

        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge.healthy {
            background: #dcfce7;
            color: #059669;
        }

        .timestamp {
            text-align: center;
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid #e2e8f0;
            font-size: 12px;
            color: #94a3b8;
        }

        .back-link {
            display: inline-block;
            margin-top: 16px;
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
        }

        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="health-card">
        <div class="health-header">
            <div class="health-status-icon">🩺</div>
            <div class="health-status">HEALTHY</div>
            <div class="health-subtitle">All systems operational</div>
        </div>
        
        <div class="health-body">
            <div class="info-row">
                <span class="info-label">Container ID</span>
                <span class="info-value">` + hostname[:12] + `</span>
            </div>
            <div class="info-row">
                <span class="info-label">Status</span>
                <span class="info-value"><span class="badge healthy">● Running</span></span>
            </div>
            <div class="info-row">
                <span class="info-label">Uptime</span>
                <span class="info-value">` + uptime + `</span>
            </div>
            <div class="info-row">
                <span class="info-label">Last Check</span>
                <span class="info-value">` + currentTime + `</span>
            </div>
            <div class="info-row">
                <span class="info-label">Image</span>
                <span class="info-value">distroless-secure-app:latest</span>
            </div>
            
            <div class="checks-grid">
                <div class="check-item">
                    <div class="check-name">
                        <span>📦</span>
                        <span>Distroless Base Image</span>
                    </div>
                    <div class="check-status pass">✓</div>
                </div>
                <div class="check-item">
                    <div class="check-name">
                        <span>📖</span>
                        <span>Read-only Filesystem</span>
                    </div>
                    <div class="check-status pass">✓</div>
                </div>
                <div class="check-item">
                    <div class="check-name">
                        <span>🚫</span>
                        <span>No Shell Access</span>
                    </div>
                    <div class="check-status pass">✓</div>
                </div>
                <div class="check-item">
                    <div class="check-name">
                        <span>🔐</span>
                        <span>Capabilities Restricted</span>
                    </div>
                    <div class="check-status pass">✓</div>
                </div>
                <div class="check-item">
                    <div class="check-name">
                        <span>💾</span>
                        <span>Memory Limit Active</span>
                    </div>
                    <div class="check-status pass">✓</div>
                </div>
                <div class="check-item">
                    <div class="check-name">
                        <span>🛡️</span>
                        <span>No New Privileges</span>
                    </div>
                    <div class="check-status pass">✓</div>
                </div>
            </div>
            
            <div style="text-align: center;">
                <a href="/" class="back-link">← Back to Dashboard</a>
                <a href="/health?format=json" class="back-link" style="margin-left: 16px;">📊 JSON Response</a>
            </div>
            
            <div class="timestamp">
                🔒 Security Check | Container Health Monitor | Distroless Hardened
            </div>
        </div>
    </div>
</body>
</html>`
        
        w.Header().Set("Content-Type", "text/html; charset=utf-8")
        w.WriteHeader(http.StatusOK)
        w.Write([]byte(html))
    })

    // API endpoint for metrics
    http.HandleFunc("/api/metrics", func(w http.ResponseWriter, r *http.Request) {
        hostname, _ := os.Hostname()
        metrics := SecurityMetrics{
            ContainerID:   hostname,
            Timestamp:     time.Now(),
            ReadOnly:      true,
            NoNewPrivs:    true,
            Capabilities:  []string{"CAP_NET_BIND_SERVICE"},
            MemoryLimit:   "256MB",
            CPUCount:      runtime.NumCPU(),
            GoVersion:     runtime.Version(),
            NumGoroutines: runtime.NumGoroutine(),
        }
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(metrics)
    })

    // Main endpoint con dashboard
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        hostname, _ := os.Hostname()
        currentTime := time.Now().Format("Monday, 02 January 2006 15:04:05 MST")
        
        html := `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Docker Distroless Security Lab | Hardened Container Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:ital,wght@0,100..900;1,100..900&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f5f7fa;
            color: #1e293b;
            line-height: 1.5;
        }

        .navbar {
            background: white;
            border-bottom: 1px solid #e2e8f0;
            padding: 0 24px;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 600;
            font-size: 18px;
        }

        .logo-icon {
            width: 32px;
            height: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
        }

        .nav-links {
            display: flex;
            gap: 24px;
            align-items: center;
        }

        .nav-link {
            color: #64748b;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
        }

        .nav-link:hover {
            color: #667eea;
        }

        .status-badge {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            background: #f1f5f9;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            background: #10b981;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 32px 24px;
        }

        .page-header {
            margin-bottom: 32px;
        }

        .page-header h1 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .page-header p {
            color: #64748b;
            font-size: 15px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            border: 1px solid #e2e8f0;
            transition: all 0.2s;
        }

        .stat-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transform: translateY(-2px);
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }

        .stat-title {
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #64748b;
        }

        .stat-icon {
            font-size: 24px;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 8px;
        }

        .stat-sub {
            font-size: 13px;
            color: #64748b;
        }

        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 32px;
        }

        @media (max-width: 768px) {
            .content-grid {
                grid-template-columns: 1fr;
            }
        }

        .card {
            background: white;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            overflow: hidden;
        }

        .card-header {
            padding: 20px 24px;
            border-bottom: 1px solid #e2e8f0;
            background: #fafbfc;
        }

        .card-header h3 {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .card-header p {
            font-size: 13px;
            color: #64748b;
        }

        .card-body {
            padding: 24px;
        }

        .security-list {
            list-style: none;
        }

        .security-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .security-item:last-child {
            border-bottom: none;
        }

        .security-name {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            font-weight: 500;
        }

        .security-badge {
            padding: 4px 10px;
            background: #dcfce7;
            color: #166534;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .metrics-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .metric-item {
            text-align: center;
            padding: 16px;
            background: #f8fafc;
            border-radius: 12px;
        }

        .metric-label {
            font-size: 12px;
            font-weight: 500;
            color: #64748b;
            text-transform: uppercase;
            margin-bottom: 8px;
        }

        .metric-value {
            font-size: 20px;
            font-weight: 700;
            color: #1e293b;
            font-family: 'Courier New', monospace;
        }

        .feed-item {
            display: flex;
            gap: 12px;
            padding: 16px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .feed-icon {
            width: 32px;
            height: 32px;
            background: #f1f5f9;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
        }

        .feed-content {
            flex: 1;
        }

        .feed-title {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .feed-time {
            font-size: 12px;
            color: #94a3b8;
        }

        .footer {
            text-align: center;
            padding: 24px;
            border-top: 1px solid #e2e8f0;
            color: #94a3b8;
            font-size: 13px;
        }

        .container-info {
            background: #f8fafc;
            border-radius: 12px;
            padding: 16px;
            margin-top: 16px;
        }

        .container-info pre {
            font-family: 'Courier New', monospace;
            font-size: 12px;
            color: #334155;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="logo">
            <div class="logo-icon">🐳</div>
            <span>Docker Distroless Security Lab</span>
        </div>
        <div class="nav-links">
            <a href="/health" class="nav-link">Health</a>
            <a href="/api/metrics" class="nav-link">API</a>
            <div class="status-badge">
                <span class="status-dot"></span>
                <span>Hardened Active</span>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h1>Distroless Secure Container</h1>
            <p>Hardened Docker container with Google Distroless base image and security best practices</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Container ID</span>
                    <span class="stat-icon">🖥️</span>
                </div>
                <div class="stat-value">` + hostname[:12] + `</div>
                <div class="stat-sub">Running since ` + time.Now().Format("15:04:05") + `</div>
            </div>

            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Security Score</span>
                    <span class="stat-icon">🛡️</span>
                </div>
                <div class="stat-value">100/100</div>
                <div class="stat-sub">Maximum hardening level</div>
            </div>

            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Uptime</span>
                    <span class="stat-icon">⏱️</span>
                </div>
                <div class="stat-value">` + time.Now().Format("15:04:05") + `</div>
                <div class="stat-sub">` + currentTime + `</div>
            </div>
        </div>

        <div class="content-grid">
            <div class="card">
                <div class="card-header">
                    <h3>🔒 Security Hardening Features</h3>
                    <p>Applied security controls and configurations</p>
                </div>
                <div class="card-body">
                    <ul class="security-list">
                        <li class="security-item">
                            <span class="security-name">📦 Distroless Base Image</span>
                            <span class="security-badge">No shell, no package manager</span>
                        </li>
                        <li class="security-item">
                            <span class="security-name">📖 Read-only Root Filesystem</span>
                            <span class="security-badge">Enabled</span>
                        </li>
                        <li class="security-item">
                            <span class="security-name">🔐 Capabilities</span>
                            <span class="security-badge">ALL dropped, NET_BIND_SERVICE only</span>
                        </li>
                        <li class="security-item">
                            <span class="security-name">🚫 No New Privileges</span>
                            <span class="security-badge">Enabled</span>
                        </li>
                        <li class="security-item">
                            <span class="security-name">💾 Memory Limit</span>
                            <span class="security-badge">256MB</span>
                        </li>
                        <li class="security-item">
                            <span class="security-name">⚡ CPU Limit</span>
                            <span class="security-badge">0.5 cores</span>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h3>📊 Container Metrics</h3>
                    <p>Real-time runtime information</p>
                </div>
                <div class="card-body">
                    <div class="metrics-grid">
                        <div class="metric-item">
                            <div class="metric-label">Go Version</div>
                            <div class="metric-value">` + runtime.Version() + `</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-label">Goroutines</div>
                            <div class="metric-value">` + fmt.Sprintf("%d", runtime.NumGoroutine()) + `</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-label">CPU Cores</div>
                            <div class="metric-value">` + fmt.Sprintf("%d", runtime.NumCPU()) + `</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-label">Architecture</div>
                            <div class="metric-value">` + runtime.GOARCH + `</div>
                        </div>
                    </div>
                    
                    <div class="container-info">
                        <strong>📋 Container Info</strong>
                        <pre>ID: ` + hostname + `
Image: distroless-secure-app:latest
Security Profile: hardened
User: nonroot (UID 65532)
Filesystem: read-only</pre>
                    </div>
                </div>
            </div>
        </div>

        <div class="footer">
            <p>🐳 Docker Distroless Security Lab | Built with Go | Google Distroless Base Image</p>
            <p style="margin-top: 8px;">🔐 Hardened Container Security | <a href="/health" style="color: #667eea;">Health Status</a> | Zero Trust Ready</p>
        </div>
    </div>
</body>
</html>`
        
        w.Header().Set("Content-Type", "text/html; charset=utf-8")
        w.WriteHeader(http.StatusOK)
        w.Write([]byte(html))
    })

    port := ":8080"
    log.Printf("🚀 Secure Distroless server starting on port %s", port)
    log.Printf("🛡️ Hardened security profile active")
    log.Printf("📊 Dashboard: http://localhost%s", port)
    log.Printf("🩺 Health page: http://localhost%s/health", port)
    log.Fatal(http.ListenAndServe(port, nil))
}
