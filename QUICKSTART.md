# 🚀 Smart System Health Monitor - Quick Start Guide

## ✅ System Status: FULLY OPERATIONAL

All services are running and the dashboard is displaying real-time metrics!

---

## 📍 Access URLs

### Grafana Dashboard (Main Interface)

- **URL**: http://localhost:3000
- **Username**: `admin`
- **Password**: `admin`
- **Dashboard**: Navigate to **Dashboards** → **Smart System Health Monitor**
- **Direct Link**: http://localhost:3000/d/smart-health-monitor/smart-system-health-monitor

### Prometheus (Metrics & Queries)

- **URL**: http://localhost:19090
- **Targets**: http://localhost:19090/targets
- **Alerts**: http://localhost:19090/alerts
- **Graph**: http://localhost:19090/graph

### Node Exporter (Raw Metrics)

- **URL**: http://localhost:9100/metrics

---

## 🎯 What You're Monitoring

The dashboard displays:

### System Overview

- ✅ **CPU Usage**: Real-time CPU utilization across all cores
- ✅ **Memory Usage**: RAM consumption percentage
- ✅ **Disk Usage**: Root partition usage
- ✅ **System Uptime**: Time since last boot

### Smart Analytics

- 🎯 **Health Score Gauge**: Composite score (0-100) with color zones
  - Formula: `(CPU × 0.4) + (Memory × 0.4) + (Disk × 0.2)`
  - Green (0-50): Healthy
  - Yellow (50-75): Moderate load
  - Orange (75-90): High load
  - Red (90-100): Critical

### Predictive Analytics

- 🔮 **10-Minute CPU Forecast**: Predicts CPU saturation before it happens
- 🔮 **Memory Exhaustion Prediction**: Forecasts memory depletion
- 🚨 **Risk Indicator**: 🟢 Safe / 🟡 At Risk / 🔴 Critical

### Resource Trends

- 📊 CPU usage by core (time series)
- 📊 Memory usage trend
- 📊 Disk I/O operations
- 📊 Load average (1m, 5m, 15m)

---

## 🎮 Quick Commands

### Start the Monitoring Stack

```bash
cd smart-system-health-monitor
./run.sh
```

### Stop the Monitoring Stack

```bash
# Stop services (preserve data)
./stop.sh

# Stop and clean all data
./stop.sh --clean
```

### Check Service Status

```bash
docker compose ps
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f node-exporter
```

### Restart a Service

```bash
docker compose restart grafana
docker compose restart prometheus
```

---

## 🧪 Demo Mode - Test Alerts

Generate system load to trigger predictive alerts:

```bash
# Generate load for 5 minutes (default)
./scripts/load_generator.sh

# Generate load for 10 minutes
./scripts/load_generator.sh 600

# Stop early with Ctrl+C
```

**Expected Behavior:**

1. Health score increases from green → yellow → orange
2. Predictive graphs show declining trends
3. Risk indicator changes from 🟢 → 🟡 → 🔴
4. Alerts start firing in the "Active Alerts" panel
5. You can see the predictions 10 minutes ahead

---

## 🔧 Important Port Information

### Why Different Ports?

**Internal Docker Network** (container-to-container):

- Prometheus: `http://prometheus:9090` ← Grafana uses this
- Node Exporter: `http://node-exporter:9100`

**External Access** (from your browser):

- Prometheus: `http://localhost:19090` ← You use this
- Grafana: `http://localhost:3000`
- Node Exporter: `http://localhost:9100`

> **Note**: Port 19090 is used externally instead of 9090 to avoid conflicts with other services on your machine. Internally, Prometheus still runs on port 9090.

---

## 📊 Current System Metrics (Example Values)

Example metrics from a typical system:

- **CPU Usage**: ~24%
- **Memory Usage**: ~70%
- **Disk Usage**: ~87%
- **Uptime**: 3.37 days

All metrics are updating every 10-15 seconds!

---

## 🎓 Key Features Demonstrated

### DevOps & SRE Skills

- ✅ Docker containerization
- ✅ Infrastructure as Code (docker-compose.yml)
- ✅ Automated provisioning (Grafana dashboards & datasources)
- ✅ Monitoring stack deployment
- ✅ Alert rule configuration

### Observability Engineering

- ✅ Time-series metrics collection
- ✅ PromQL query optimization
- ✅ Custom metric aggregation
- ✅ Predictive analytics using linear regression
- ✅ Composite health scoring algorithm

### Production Readiness

- ✅ Comprehensive documentation
- ✅ Operational scripts (run.sh, stop.sh)
- ✅ Load testing capabilities
- ✅ Alert management
- ✅ Data persistence

---

## 🐛 Troubleshooting

### Dashboard Shows "No Data"

**Solution**: Already fixed! The datasource UID has been corrected.

### Services Won't Start

```bash
# Check Docker is running
docker info

# Restart all services
docker compose down
docker compose up -d
```

### Port Conflicts

If you see "address already in use" errors, the ports are already configured to avoid conflicts:

- Prometheus: 19090 (instead of 9090)
- Grafana: 3000
- Node Exporter: 9100

### Grafana Login Issues

- Default credentials: `admin` / `admin`
- You'll be prompted to change password on first login (can skip)

---

## 📁 Project Structure

```
smart-system-health-monitor/
├── prometheus/
│   ├── prometheus.yml          # Metrics collection config
│   └── alert_rules.yml         # 10+ intelligent alerts
├── grafana/
│   ├── dashboards/
│   │   └── system_health_dashboard.json  # 17-panel dashboard
│   └── provisioning/
│       ├── datasources/
│       │   └── datasources.yml # Auto-configured Prometheus
│       └── dashboards/
│           └── dashboards.yml  # Dashboard auto-loading
├── scripts/
│   └── load_generator.sh       # Demo load testing
├── docker-compose.yml          # Service orchestration
├── run.sh                      # One-command startup
├── stop.sh                     # Graceful shutdown
├── README.md                   # Full documentation
└── QUICKSTART.md              # This file
```

---

## 🎯 Next Steps

1. **Explore the Dashboard**

   - Open http://localhost:3000/d/smart-health-monitor/smart-system-health-monitor
   - Scroll through all 6 rows of panels
   - Watch metrics update in real-time

2. **Test Predictive Alerts**

   - Run `./scripts/load_generator.sh`
   - Watch the health score increase
   - See predictions change from 🟢 to 🟡 to 🔴

3. **Customize Alerts**

   - Edit `prometheus/alert_rules.yml`
   - Adjust thresholds (e.g., change 75% to 80%)
   - Restart Prometheus: `docker compose restart prometheus`

4. **Add More Metrics**
   - Explore Node Exporter metrics: http://localhost:9100/metrics
   - Add new panels to the dashboard
   - Create custom PromQL queries

---

## 📞 Support

For issues or questions:

1. Check the full README.md for detailed documentation
2. Review Prometheus logs: `docker compose logs prometheus`
3. Review Grafana logs: `docker compose logs grafana`
4. Verify all services are up: `docker compose ps`

---

## 🎉 Success!

Your Smart System Health Monitor is fully operational and ready for:

- ✅ Portfolio demonstrations
- ✅ Technical interviews
- ✅ Production deployment
- ✅ Resume showcasing

**Built with ❤️ for DevOps, SRE, and observability excellence**
