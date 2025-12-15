import { NextRequest, NextResponse } from 'next/server';

// Track application start time for uptime calculation
const startTime = Date.now();

/**
 * Enterprise-grade health check endpoint
 *
 * This endpoint provides comprehensive health status information including:
 * - Application status
 * - Uptime in seconds
 * - Memory usage statistics
 * - ISO timestamp
 *
 * Returns:
 * - 200 OK when the application is healthy
 * - Includes detailed metrics for monitoring and observability
 *
 * Security: This endpoint is intentionally public for Kubernetes probes
 * and monitoring systems. No sensitive information is exposed.
 */
export async function GET(request: NextRequest) {
  try {
    // Calculate uptime in seconds
    const uptimeSeconds = Math.floor((Date.now() - startTime) / 1000);

    // Get memory usage (only available in Node.js runtime)
    const memoryUsage = process.memoryUsage();
    const memoryUsageMB = {
      rss: Math.round(memoryUsage.rss / 1024 / 1024),
      heapTotal: Math.round(memoryUsage.heapTotal / 1024 / 1024),
      heapUsed: Math.round(memoryUsage.heapUsed / 1024 / 1024),
      external: Math.round(memoryUsage.external / 1024 / 1024),
    };

    // Return comprehensive health status
    return NextResponse.json(
      {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: uptimeSeconds,
        memory: memoryUsageMB,
        environment: process.env.NODE_ENV || 'unknown',
      },
      {
        status: 200,
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      }
    );
  } catch (error) {
    // If health check fails, return 503 Service Unavailable
    console.error('Health check failed:', error);
    return NextResponse.json(
      {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      {
        status: 503,
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
        },
      }
    );
  }
}

// Support HEAD requests for lightweight health checks
export async function HEAD(request: NextRequest) {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Cache-Control': 'no-cache, no-store, must-revalidate',
    },
  });
}
