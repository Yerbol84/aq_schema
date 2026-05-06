/// Cache domain — универсальный мультитонный кэш платформы AQ.
library cache;

// Interfaces
export 'interfaces/i_aq_cache.dart';
export 'interfaces/i_aq_cacheable.dart';
export 'interfaces/i_aq_cache_storage.dart';
export 'interfaces/i_aq_cache_eviction_policy.dart';
export 'interfaces/i_aq_cache_validator.dart';
export 'interfaces/i_aq_cache_manager.dart';

// Models
export 'models/cache_entry.dart';
export 'models/cache_config.dart';
