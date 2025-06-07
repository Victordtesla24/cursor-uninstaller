/**
 * @fileoverview
 * Result Cache - Standard result caching for the Revolutionary AI system.
 */

class ResultCache {
  constructor(config = {}) {
    this.config = config;
    this.cache = new Map();
    this.maxSize = config.maxSize || 1000;
    this.ttl = config.ttl || 3600000; // 1 hour default
    this.stats = { hits: 0, misses: 0, sets: 0 };
    console.log('[Result Cache] Initialized for standard result caching');
  }

  async get(key) {
    const entry = this.cache.get(key);
    
    if (!entry) {
      this.stats.misses++;
      return null;
    }

    // Check TTL
    if (Date.now() > entry.expiry) {
      this.cache.delete(key);
      this.stats.misses++;
      return null;
    }

    this.stats.hits++;
    entry.lastAccess = Date.now();
    return entry.value;
  }

  async set(key, value, options = {}) {
    const ttl = options.ttl || this.ttl;
    const expiry = Date.now() + ttl;

    // Evict if at max size
    if (this.cache.size >= this.maxSize) {
      this._evictLRU();
    }

    this.cache.set(key, {
      value,
      expiry,
      lastAccess: Date.now(),
      created: Date.now()
    });

    this.stats.sets++;
  }

  async delete(key) {
    return this.cache.delete(key);
  }

  async clear() {
    this.cache.clear();
    this.stats = { hits: 0, misses: 0, sets: 0 };
  }

  _evictLRU() {
    let oldestKey = null;
    let oldestTime = Date.now();

    for (const [key, entry] of this.cache.entries()) {
      if (entry.lastAccess < oldestTime) {
        oldestTime = entry.lastAccess;
        oldestKey = key;
      }
    }

    if (oldestKey) {
      this.cache.delete(oldestKey);
    }
  }

  getStats() {
    const total = this.stats.hits + this.stats.misses;
    const hitRate = total > 0 ? (this.stats.hits / total) * 100 : 0;
    return {
      ...this.stats,
      hitRate: hitRate,
      size: this.cache.size
    };
  }

  getSize() {
    return this.cache.size;
  }

  getMemoryUsage() {
    // Estimate memory usage in MB
    let totalSize = 0;
    for (const [key, value] of this.cache) {
      totalSize += JSON.stringify({ key, value }).length;
    }
    return Math.round(totalSize / (1024 * 1024) * 100) / 100; // Convert to MB
  }

  getMemoryUtilization() {
    return this.getSize() / this.maxSize;
  }

  clear() {
    this.cache.clear();
    this.stats = { hits: 0, misses: 0, sets: 0 };
    console.log('[Result Cache] Cache cleared');
  }
}

module.exports = { ResultCache }; 