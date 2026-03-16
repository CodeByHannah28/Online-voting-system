package com.bascode.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.lang.management.OperatingSystemMXBean;
import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "AdminMonitor", urlPatterns = {"/admin/monitor"})
public class AdminMonitorServlet extends HttpServlet {

    private static final Instant started = Instant.now();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        MemoryMXBean mem = ManagementFactory.getMemoryMXBean();
        MemoryUsage heap = mem.getHeapMemoryUsage();

        OperatingSystemMXBean os = ManagementFactory.getOperatingSystemMXBean();

        Map<String, Object> stats = new HashMap<>();
        stats.put("heapInit", heap.getInit());
        stats.put("heapUsed", heap.getUsed());
        stats.put("heapCommitted", heap.getCommitted());
        stats.put("heapMax", heap.getMax());
        stats.put("heapUsagePercent", (double) heap.getUsed() / heap.getMax() * 100);
        
        stats.put("osName", os.getName());
        stats.put("osArch", os.getArch());
        stats.put("osVersion", os.getVersion());
        stats.put("availableProcessors", os.getAvailableProcessors());
        stats.put("systemLoadAverage", os.getSystemLoadAverage());
        
        stats.put("uptimeSeconds", Duration.between(started, Instant.now()).getSeconds());
        stats.put("threadCount", ManagementFactory.getThreadMXBean().getThreadCount());
        stats.put("peakThreadCount", ManagementFactory.getThreadMXBean().getPeakThreadCount());

        req.setAttribute("stats", stats);
        req.getRequestDispatcher("/admin/monitor.jsp").forward(req, resp);
    }
}
