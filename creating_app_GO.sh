#!/bin/bash
# ============================================
# PASO 2.2: CREAR APLICACIÓN GO
# ============================================

echo "=== PASO 2.2: Crear Aplicación Go ==="

cd $HOME/distroless-lab

# Crear main.go
echo "1. Creando main.go..."
cat > app/main.go << 'EOF'
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

type HealthResponse struct {
    Status    string    `json:"status"`
    Timestamp time.Time `json:"timestamp"`
    Container string    `json:"container_id"`
    Uptime    string    `json:"uptime"`
}

type MetricsResponse struct {
    GoVersion   string `json:"go_version"`
    NumCPU      int    `json:"num_cpu"`
    NumGoroutines int `json:"num_goroutines"`
    ContainerID string `json:"container_id"`
    MemoryUsage string `json:"memory_usage_mb"`
}

var startTime time.Time

func init() {
    startTime = time.Now()
}

func main() {
    hostname, _ := os.Hostname()

    // Health endpoint - HTML y JSON
    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        accept := r.Header.Get("Accept")
        
        response := HealthResponse{
            Status:    "healthy",
            Timestamp: time.Now(),
            Container: hostname,
            Uptime:    time.Since(startTime).String(),
        }
        
        if accept == "application/json" {
            w.Header().Set("Content-Type", "application/json")
            json.NewEncoder(w).Encode(response)
        } else {
            w.Header().Set("Content-Type", "text/html")
            html := fmt.Sprintf(`<!DOCTYPE html>
            <html><head><title>Health Check</title></head>
            <body>
                <h1>✅ Container Health</h1>
                <p>Status: %s</p>
                <p>Container: %s</p>
                <p>Uptime: %s</p>
                <p><a href="/">Home</a></p>
            </body></html>`,
                response.Status, response.Container, response.Uptime)
            w.Write([]byte(html))
        }
    })

    // Metrics endpoint
    http.HandleFunc("/api/metrics", func(w http.ResponseWriter, r *http.Request) {
        var m runtime.MemStats
        runtime.ReadMemStats(&m)
        
        metrics := MetricsResponse{
            GoVersion:     runtime.Version(),
            NumCPU:        runtime.NumCPU(),
            NumGoroutines: runtime.NumGoroutine(),
            ContainerID:   hostname,
            MemoryUsage:   fmt.Sprintf("%.2f MB", float64(m.Alloc)/1024/1024),
        }
        
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(metrics)
    })

    // Dashboard principal
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        html := fmt.Sprintf(`<!DOCTYPE html>
        <html>
        <head>
            <title>Distroless Secure Lab</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; 
                       margin: 40px; background: #f5f5f5; }
                .container { background: white; padding: 30px; border-radius: 8px; 
                             box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 600px; }
                h1 { color: #1a73e8; }
                .stat { background: #f0f0f0; padding: 10px; margin: 10px 0; 
                        border-radius: 4px; }
                a { color: #1a73e8; text-decoration: none; margin-right: 20px; }
                a:hover { text-decoration: underline; }
                .badge { display: inline-block; background: #c8e6c9; 
                         color: #2e7d32; padding: 5px 10px; border-radius: 4px; 
                         margin-right: 10px; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🔒 Distroless Secure Container</h1>
                <p>Welcome to the Docker Distroless Security Lab</p>
                
                <div class="stat">
                    <strong>Container ID:</strong> %s
                </div>
                <div class="stat">
                    <strong>Uptime:</strong> %s
                </div>
                <div class="stat">
                    <strong>Go Version:</strong> %s
                </div>
                
                <h2>Security Features</h2>
                <span class="badge">No Shell</span>
                <span class="badge">Read-only FS</span>
                <span class="badge">Min Capabilities</span>
                <span class="badge">Non-root User</span>
                
                <h2>Navigation</h2>
                <a href="/health">Health Check</a>
                <a href="/api/metrics">Metrics API</a>
                
                <hr>
                <small>Last updated: %s</small>
            </div>
        </body>
        </html>`,
            hostname,
            time.Since(startTime).String(),
            runtime.Version(),
            time.Now().Format(time.RFC3339))
        
        w.Header().Set("Content-Type", "text/html")
        w.Write([]byte(html))
    })

    log.Println("🚀 Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF

# Crear go.mod
echo "2. Creando go.mod..."
cat > app/go.mod << 'EOF'
module distroless-lab

go 1.22
EOF

# Verificar archivos
echo ""
echo "3. Archivos creados:"
ls -lah app/

echo ""
echo "✅ PASO 2.2 COMPLETADO"
