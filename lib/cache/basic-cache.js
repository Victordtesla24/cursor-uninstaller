/**
 * @fileoverview
 * Basic Cache Implementation
 * 
 * Simple in-memory cache with basic LRU eviction.
 * No persistence, no "revolutionary" features.
 */

class BasicCache {
  constructor(config = {}) {
    this.maxItems = config.maxItems || 100;
    this.cache = new Map();
    this.accessOrder = [];
  }

  /**
   * Get item from cache
   */
  get(key) {
    if (!this.cache.has(key)) {
      return null;
    }

    // Update access order for LRU
    const index = this.accessOrder.indexOf(key);
    if (index > -1) {
      this.accessOrder.splice(index, 1);
    }
    this.accessOrder.push(key);

    return this.cache.get(key);
  }

  /**
   * Set item in cache
   */
  set(key, value) {
    // Remove oldest item if at capacity
    if (this.cache.size >= this.maxItems && !this.cache.has(key)) {
      const oldestKey = this.accessOrder.shift();
      this.cache.delete(oldestKey);
    }

    this.cache.set(key, value);
    
    // Update access order
    const index = this.accessOrder.indexOf(key);
    if (index > -1) {
      this.accessOrder.splice(index, 1);
    }
    this.accessOrder.push(key);

    return true;
  }

  /**
   * Clear all cache entries
   */
  clear() {
    this.cache.clear();
    this.accessOrder = [];
  }

  /**
   * Get cache statistics
   */
  getStats() {
    return {
      size: this.cache.size,
      maxItems: this.maxItems,
      type: 'basic-lru',
      persistence: false
    };
  }
}

module.exports = BasicCache;
