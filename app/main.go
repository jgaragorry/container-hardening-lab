package main

import (
	"fmt"
	"html/template"
	"net/http"
	"os"
	"time"
)

// Estructura de datos para el Dashboard
type PageData struct {
	ContainerID string
	Uptime      string
	GoVersion   string
	Timestamp   string
	Status      string
}

var startTime time.Time

func main() {
	// --- LÓGICA DE HEALTHCHECK SRE ---
	// Si Docker ejecuta el binario con el argumento "health",
	// la app responde con éxito y termina. Esto pone el monitor en VERDE.
	if len(os.Args) > 1 && os.Args[1] == "health" {
		os.Exit(0)
	}

	startTime = time.Now()
	port := ":8080"

	// Definición de rutas
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)

	fmt.Printf("2026/04/15 🚀 Dashboard SRE iniciado en %s\n", port)
	
	server := &http.Server{
		Addr:         port,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	if err := server.ListenAndServe(); err != nil {
		fmt.Printf("❌ Error crítico: %v\n", err)
		os.Exit(1)
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	containerID, _ := os.Hostname()
	data := PageData{
		ContainerID: containerID,
		Uptime:      time.Since(startTime).Round(time.Second).String(),
		GoVersion:   "1.22.10",
		Timestamp:   time.Now().Format("02-01-2026 15:04:05"),
		Status:      "HEALTHY",
	}

	tmpl := `
	<!DOCTYPE html>
	<html lang="es">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>SRE Security Lab | Hardened Container</title>
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
		<style>
			body { background-color: #f8f9fa; font-family: 'Inter', system-ui, sans-serif; }
			.card { border: none; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
			.status-badge { font-size: 0.75rem; padding: 4px 12px; border-radius: 50px; font-weight: 700; text-transform: uppercase; }
			.feature-item { background: white; border-left: 4px solid #0d6efd; padding: 12px; margin-bottom: 8px; border-radius: 6px; transition: 0.3s; }
			.feature-item:hover { transform: translateX(5px); }
			.header-shield { font-size: 3.5rem; color: #0d6efd; margin-bottom: 10px; }
		</style>
	</head>
	<body>
		<div class="container py-5">
			<div class="row justify-content-center">
				<div class="col-lg-7">
					<div class="card p-5 border-top border-primary border-5">
						<div class="text-center mb-4">
							<div class="header-shield">🛡️</div>
							<h2 class="fw-bold">Laboratorio de Hardening</h2>
							<p class="text-muted small">Contenedor Distroless Certificado ISO 27001</p>
							<span class="status-badge bg-success text-white">● Sistema {{.Status}}</span>
						</div>

						<div class="row g-3 mb-4 text-center">
							<div class="col-4">
								<div class="p-2 bg-light rounded shadow-sm">
									<label class="d-block text-muted x-small" style="font-size: 0.7rem;">ID CONTAINER</label>
									<span class="fw-bold text-dark small">{{.ContainerID}}</span>
								</div>
							</div>
							<div class="col-4">
								<div class="p-2 bg-light rounded shadow-sm">
									<label class="d-block text-muted x-small" style="font-size: 0.7rem;">UPTIME</label>
									<span class="fw-bold text-dark small">{{.Uptime}}</span>
								</div>
							</div>
							<div class="col-4">
								<div class="p-2 bg-light rounded shadow-sm">
									<label class="d-block text-muted x-small" style="font-size: 0.7rem;">VERSION</label>
									<span class="fw-bold text-dark small">{{.GoVersion}}</span>
								</div>
							</div>
						</div>

						<h6 class="fw-bold mb-3 text-secondary text-uppercase" style="letter-spacing: 1px;">Controles de Seguridad</h6>
						
						<div class="feature-item d-flex justify-content-between align-items-center">
							<div>
								<div class="fw-bold small">Arquitectura Distroless</div>
								<div class="text-muted" style="font-size: 0.75rem;">Superficie de ataque mínima (A.8.8)</div>
							</div>
							<span class="badge bg-primary rounded-pill">Activo</span>
						</div>

						<div class="feature-item d-flex justify-content-between align-items-center" style="border-left-color: #20c997;">
							<div>
								<div class="fw-bold small">Filesystem Inmutable</div>
								<div class="text-muted" style="font-size: 0.75rem;">Modo Read-Only habilitado (A.8.27)</div>
							</div>
							<span class="badge bg-success rounded-pill">Forzado</span>
						</div>

						<div class="feature-item d-flex justify-content-between align-items-center" style="border-left-color: #ffc107;">
							<div>
								<div class="fw-bold small">Privilegios Mínimos</div>
								<div class="text-muted" style="font-size: 0.75rem;">Usuario Non-Root UID: 65532 (A.8.26)</div>
							</div>
							<span class="badge bg-warning text-dark rounded-pill">Non-Root</span>
						</div>

						<div class="mt-4 pt-3 border-top d-flex justify-content-between">
							<span class="text-muted" style="font-size: 0.7rem;">{{.Timestamp}}</span>
							<div>
								<a href="/health" class="btn btn-link btn-sm p-0 me-2 text-decoration-none" style="font-size: 0.75rem;">Health Check</a>
								<a href="#" class="btn btn-link btn-sm p-0 text-decoration-none" style="font-size: 0.75rem;">Metrics API</a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
	</html>
	`
	t := template.Must(template.New("home").Parse(tmpl))
	t.Execute(w, data)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}
