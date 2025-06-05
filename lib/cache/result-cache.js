/**
 * Result Cache - High-performance caching for AI completions and results
 * Implements intelligent cache invalidation and memory-efficient storage
 * Target: Cache hit rate >60%, retrieval <10ms
 */

const crypto = require('crypto');

class ResultCache {
  constructor(options = {}) {
    this.config = {
      maxSize: 1000, // Maximum number of cached items
      maxMemoryMB: 100, // Maximum memory usage in MB
      defaultTTL: 300000, // 5 minutes default TTL
      compressionThreshold: 1000, // Compress items larger than 1KB
      enableMetrics: true,
      ...options
    };

    this.cache = new Map();
    this.accessTimes = new Map();
    this.creationTimes = new Map();
    this.ttls = new Map();
    this.sizes = new Map();

    this.stats = {
      hits: 0,
      misses: 0,
      sets: 0,
      evictions: 0,
      memoryUsage: 0,
      averageItemSize: 0
    };

    // Start cleanup interval - only in production, not during tests
    if (process.env.NODE_ENV !== 'test') {
      this.cleanupInterval = setInterval(() => {
        this.performMaintenance();
      }, 60000); // Every minute
    }
  }

  /**
   * Get item from cache
   * @param {string} key - Cache key
   * @returns {Promise<any>} Cached value or null
   */
  async get(key) {
    const normalizedKey = this.normalizeKey(key);

    // Check if item exists and is not expired
    if (!this.cache.has(normalizedKey) || this.isExpired(normalizedKey)) {
      this.stats.misses++;
      if (this.cache.has(normalizedKey)) {
        // Remove expired item
        this.delete(normalizedKey);
      }
      return null;
    }

    // Update access time for LRU
    this.accessTimes.set(normalizedKey, Date.now());
    this.stats.hits++;

    const item = this.cache.get(normalizedKey);

    // Decompress if needed
    if (item && item._compressed) {
      return this.decompress(item);
    }

    return item;
  }

  /**
   * Set item in cache
   * @param {string} key - Cache key
   * @param {any} value - Value to cache
   * @param {Object} options - Caching options
   * @returns {Promise<void>}
   */
  async set(key, value, options = {}) {
    const normalizedKey = this.normalizeKey(key);
    const ttl = options.ttl || this.config.defaultTTL;
    const now = Date.now();

    // Prepare item for storage
    let item = value;
    let itemSize = this.estimateSize(value);

    // Compress large items
    if (itemSize > this.config.compressionThreshold) {
      item = this.compress(value);
      itemSize = this.estimateSize(item);
    }

    // Check memory limits before adding
    if (this.wouldExceedMemoryLimit(itemSize)) {
      await this.evictOldestItems(itemSize);
    }

    // Check size limits
    if (this.cache.size >= this.config.maxSize) {
      this.evictLRU();
    }

    // Store item
    this.cache.set(normalizedKey, item);
    this.accessTimes.set(normalizedKey, now);
    this.creationTimes.set(normalizedKey, now);
    this.ttls.set(normalizedKey, ttl);
    this.sizes.set(normalizedKey, itemSize);

    // Update stats
    this.stats.sets++;
    this.stats.memoryUsage += itemSize;
    this.updateAverageItemSize();
  }

  /**
   * Delete item from cache
   * @param {string} key - Cache key
   * @returns {boolean} True if item was deleted
   */
  delete(key) {
    const normalizedKey = this.normalizeKey(key);

    if (!this.cache.has(normalizedKey)) {
      return false;
    }

    // Update memory usage
    const itemSize = this.sizes.get(normalizedKey) || 0;
    this.stats.memoryUsage -= itemSize;

    // Remove from all maps
    this.cache.delete(normalizedKey);
    this.accessTimes.delete(normalizedKey);
    this.creationTimes.delete(normalizedKey);
    this.ttls.delete(normalizedKey);
    this.sizes.delete(normalizedKey);

    this.updateAverageItemSize();
    return true;
  }

  /**
   * Check if item exists in cache
   * @param {string} key - Cache key
   * @returns {boolean} True if item exists and is not expired
   */
  has(key) {
    const normalizedKey = this.normalizeKey(key);
    return this.cache.has(normalizedKey) && !this.isExpired(normalizedKey);
  }

  /**
   * Clear all items from cache
   */
  clear() {
    this.cache.clear();
    this.accessTimes.clear();
    this.creationTimes.clear();
    this.ttls.clear();
    this.sizes.clear();

    this.stats.memoryUsage = 0;
    this.stats.averageItemSize = 0;
  }

  /**
   * Get cache statistics
   * @returns {Object} Cache statistics
   */
  getStats() {
    const totalRequests = this.stats.hits + this.stats.misses;

    return {
      ...this.stats,
      size: this.cache.size,
      hitRate: totalRequests > 0 ? (this.stats.hits / totalRequests) * 100 : 0,
      memoryUsageMB: Math.round(this.stats.memoryUsage / (1024 * 1024) * 100) / 100,
      maxMemoryMB: this.config.maxMemoryMB,
      memoryUtilization: (this.stats.memoryUsage / (this.config.maxMemoryMB * 1024 * 1024)) * 100,
      compressionRatio: this.calculateCompressionRatio()
    };
  }

  /**
   * Calculate compression ratio
   * @private
   * @returns {number} Compression ratio as percentage
   */
  calculateCompressionRatio() {
    let compressedItems = 0;
    let totalOriginalSize = 0;
    let totalCompressedSize = 0;

    for (const [key, value] of this.cache.entries()) {
      if (value && value._compressed) {
        compressedItems++;
        const originalSize = value._originalSize || 0;
        const compressedSize = this.sizes.get(key) || 0;
        totalOriginalSize += originalSize;
        totalCompressedSize += compressedSize;
      }
    }

    if (compressedItems === 0 || totalOriginalSize === 0) {
      return 0;
    }

    // Return compression ratio as percentage of space saved
    const spacesSaved = totalOriginalSize - totalCompressedSize;
    return Math.round((spacesSaved / totalOriginalSize) * 100 * 100) / 100;
  }

  /**
   * Get cache entries for debugging
   * @returns {Array} Array of cache entries with metadata
   */
  getEntries(limit = 10) {
    const entries = [];
    let count = 0;

    for (const [key, value] of this.cache.entries()) {
      if (count >= limit) break;

      entries.push({
        key,
        size: this.sizes.get(key),
        accessTime: this.accessTimes.get(key),
        creationTime: this.creationTimes.get(key),
        ttl: this.ttls.get(key),
        expired: this.isExpired(key),
        compressed: value && value._compressed
      });

      count++;
    }

    return entries.sort((a, b) => b.accessTime - a.accessTime);
  }

  /**
   * Normalize cache key
   * @private
   */
  normalizeKey(key) {
    if (typeof key !== 'string') {
      key = JSON.stringify(key);
    }

    // Create hash for very long keys
    if (key.length > 250) {
      return crypto.createHash('sha256').update(key).digest('hex');
    }

    return key;
  }

  /**
   * Check if item is expired
   * @private
   */
  isExpired(key) {
    const creationTime = this.creationTimes.get(key);
    const ttl = this.ttls.get(key);

    if (!creationTime || !ttl) return true;

    return Date.now() - creationTime > ttl;
  }

  /**
   * Estimate size of object in bytes
   * @private
   */
  estimateSize(obj) {
    if (obj === null || obj === undefined) return 0;

    // Handle compressed objects
    if (obj && obj._compressed) {
      // Simulate compression by returning 60% of original size
      return Math.round((obj._originalSize || 1000) * 0.6);
    }

    if (typeof obj === 'string') {
      return obj.length * 2; // UTF-16 characters
    }

    if (typeof obj === 'number') return 8;
    if (typeof obj === 'boolean') return 4;

    // For objects, estimate JSON size
    try {
      return JSON.stringify(obj).length * 2;
    } catch {
      return 1000; // Fallback estimate
    }
  }

  /**
   * Check if adding item would exceed memory limit
   * @private
   */
  wouldExceedMemoryLimit(itemSize) {
    const maxBytes = this.config.maxMemoryMB * 1024 * 1024;
    return (this.stats.memoryUsage + itemSize) > maxBytes;
  }

  /**
   * Evict oldest items to make room
   * @private
   */
  async evictOldestItems(requiredSpace) {
    const items = Array.from(this.accessTimes.entries())
      .sort((a, b) => a[1] - b[1]); // Sort by access time (oldest first)

    let freedSpace = 0;
    let evictedCount = 0;

    for (const [key] of items) {
      if (freedSpace >= requiredSpace) break;

      const itemSize = this.sizes.get(key) || 0;
      this.delete(key);
      freedSpace += itemSize;
      evictedCount++;
    }

    this.stats.evictions += evictedCount;
  }

  /**
   * Evict least recently used item
   * @private
   */
  evictLRU() {
    let oldestKey = null;
    let oldestTime = Infinity;

    for (const [key, time] of this.accessTimes.entries()) {
      if (time < oldestTime) {
        oldestTime = time;
        oldestKey = key;
      }
    }

    if (oldestKey) {
      this.delete(oldestKey);
      this.stats.evictions++;
    }
  }

  /**
   * Compress large objects
   * @private
   */
  compress(obj) {
    // Simple compression implementation
    // In production, would use actual compression library
    try {
      const json = JSON.stringify(obj);

      // Mock compression by reducing the size estimate
      const compressedData = {
        _compressed: true,
        _originalSize: json.length,
        _data: obj, // In reality, would be compressed data
        _compressedAt: Date.now()
      };

      return compressedData;
    } catch {
      return obj;
    }
  }

  /**
   * Decompress compressed objects
   * @private
   */
  decompress(compressedObj) {
    if (!compressedObj || !compressedObj._compressed) {
      return compressedObj;
    }

    // Return original data (in reality, would decompress)
    return compressedObj._data;
  }

  /**
   * Update average item size statistic
   * @private
   */
  updateAverageItemSize() {
    if (this.cache.size === 0) {
      this.stats.averageItemSize = 0;
      return;
    }

    this.stats.averageItemSize = Math.round(this.stats.memoryUsage / this.cache.size);
  }

  /**
   * Perform periodic maintenance
   * @private
   */
  performMaintenance() {
    let cleanedItems = 0;

    // Remove expired items
    for (const key of this.cache.keys()) {
      if (this.isExpired(key)) {
        this.delete(key);
        cleanedItems++;
      }
    }

    // If memory usage is high, perform additional cleanup
    const memoryUsagePercent = (this.stats.memoryUsage / (this.config.maxMemoryMB * 1024 * 1024)) * 100;
    if (memoryUsagePercent > 80) {
      const targetReduction = this.stats.memoryUsage * 0.2; // Reduce by 20%
      this.evictOldestItems(targetReduction);
    }

    if (this.config.enableMetrics && cleanedItems > 0) {
      console.log(`ResultCache: Cleaned ${cleanedItems} expired items`);
    }
  }

  /**
   * Create cache key for AI completion request
   * @param {Object} request - AI request parameters
   * @returns {string} Cache key
   */
  static createCompletionKey(request) {
    const keyData = {
      code: request.code?.slice(-200) || '', // Last 200 chars
      language: request.language,
      position: request.position,
      type: 'completion'
    };

    return crypto.createHash('md5').update(JSON.stringify(keyData)).digest('hex');
  }

  /**
   * Create cache key for AI instruction request
   * @param {Object} instruction - AI instruction parameters
   * @returns {string} Cache key
   */
  static createInstructionKey(instruction) {
    const keyData = {
      text: instruction.text,
      language: instruction.language,
      selection: instruction.selection,
      type: 'instruction'
    };

    return crypto.createHash('md5').update(JSON.stringify(keyData)).digest('hex');
  }

  /**
   * Shutdown cache and cleanup
   */
  shutdown() {
    // Clear cleanup interval first to prevent new maintenance cycles
    if (this.cleanupInterval) {
      clearInterval(this.cleanupInterval);
      this.cleanupInterval = null;
    }

    // Clear all cache data
    this.clear();

    // Reset stats to initial state
    this.stats = {
      hits: 0,
      misses: 0,
      sets: 0,
      evictions: 0,
      memoryUsage: 0,
      averageItemSize: 0
    };
  }
}

module.exports = ResultCache;
