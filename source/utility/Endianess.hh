/*
 * --- GSMP-COPYRIGHT-NOTE-BEGIN ---
 * 
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * Please add additional copyright information _after_ the line containing
 * the GSMP-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
 * the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
 * 
 * GSMP: pcm/include/Types.hh
 * General Sound Manipulation Program is Copyright (C) 2000 - 2012
 *   Valentin Ziegler and René Rebe
 * Copyright (C) 2015 - 2016 René Rebe, ExactCODE GmbH
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2. A copy of the GNU General
 * Public License can be found in the file LICENSE.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANT-
 * ABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * Alternatively, commercial licensing options are available from the
 * copyright holder ExactCODE GmbH Germany.
 *
 * --- GSMP-COPYRIGHT-NOTE-END ---
 */

/* Short Description:
 *   Advanced templates to perform automated type convertion for
 *   various kind of integer and floating point types. Convertions for
 *   the same type are entirely optimized away - and integer convertions
 *   are "normally" optimized down to a single shift instruction - of
 *   course fully inlined.
 */

#ifndef LOWLEVEL__ENDIANESS_HH__
#define LOWLEVEL__ENDIANESS_HH__

#include <sys/types.h>
#include <stdint.h>

#if defined(__FreeBSD__)
  #include <sys/endian.h>

  #define bswap_16 bswap16
  #define bswap_32 bswap32
  #define bswap_64 bswap64
#elif defined(__APPLE__)
  #include <libkern/OSByteOrder.h>
  #define bswap_16 OSSwapConstInt16
  #define bswap_32 OSSwapConstInt32
  #define bswap_64 OSSwapConstInt64
#elif defined (_MSC_VER)
  #define bswap_16 _byteswap_ushort
  #define bswap_32 _byteswap_ulong
  #define bswap_64 _byteswap_uint64
#undef __BIG_ENDIAN__
#undef BYTE_ORDER 
#else
  #include <endian.h>
  #include <byteswap.h>
#endif

namespace Exact {
  
  class EndianTraits {
  public:
    
    static const bool IsSpecialized = false;
    static const bool HasEndianess = false;
    static const bool IsBigendian = false;
  };
  
  class LittleEndianTraits : public EndianTraits {
  public:
    
    static const bool IsSpecialized = true;
    static const bool HasEndianess = true;
    static const bool IsBigendian = false;
  };

  class BigEndianTraits : public EndianTraits {
  public:
  
    static const bool IsSpecialized = true;
    static const bool HasEndianess = true;
    static const bool IsBigendian = true;
  };

#if defined(__BIG_ENDIAN__) || (defined(BYTE_ORDER) && BYTE_ORDER == BIG_ENDIAN)
  typedef BigEndianTraits NativeEndianTraits;
#else
  typedef LittleEndianTraits NativeEndianTraits;
#endif
  
  typedef BigEndianTraits NetworkEndianTraits;

  template <typename E_SRC, typename E_DEST, typename T>
  class ByteSwap {
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, int8_t> {
  public:
    inline static const int8_t Swap (const int8_t& source)
    { return source; };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, uint8_t> {
  public:
    inline static const int8_t Swap (const uint8_t& source)
    { return source; };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, int16_t> {
  public:
    inline static const int16_t Swap (const int16_t& source) {
      if (E_SRC::IsBigendian == E_DEST::IsBigendian)
	return source;
      else
	return bswap_16 (source);
    };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, uint16_t> {
  public:
    inline static const uint16_t Swap (const uint16_t& source) {
      if (E_SRC::IsBigendian == E_DEST::IsBigendian)
	return source;
      else
	return bswap_16 (source);
    };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, int32_t> {
  public:
    inline static const int32_t Swap (const int32_t& source) {
      if (E_SRC::IsBigendian == E_DEST::IsBigendian)
	return source;
      else
	return bswap_32 (source);
    };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, uint32_t> {
  public:
    inline static const uint32_t Swap (const uint32_t& source) {
      if (E_SRC::IsBigendian == E_DEST::IsBigendian)
	return source;
      else
	return bswap_32 (source);
    };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, int64_t> {
  public:
    inline static const int64_t Swap (const int64_t& source) {
      if (E_SRC::IsBigendian == E_DEST::IsBigendian)
	return source;
      else
	return bswap_64 (source);
    };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, uint64_t> {
  public:
    inline static const uint64_t Swap (const uint64_t& source) {
      if (E_SRC::IsBigendian == E_DEST::IsBigendian)
	return source;
      else
	return bswap_64 (source);
    };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, float> {
  public:
    inline static const float Swap (const float& source) {
      uint32_t* t = (uint32_t*)&source;
      if (E_SRC::IsBigendian != E_DEST::IsBigendian)
	*t = bswap_32(*t);
      
      return *(float*)t;
    };
  };

  template <typename E_SRC, typename E_DEST>
  class ByteSwap<E_SRC, E_DEST, double> {
  public:
    inline static const double Swap (const double& source) {
      uint64_t* t = (uint64_t*)&source;
      if (E_SRC::IsBigendian != E_DEST::IsBigendian)
	*t = bswap_64(*t);
      
      return *(double*)t;
    };
  };
  
  // ---
  
  // must be Plain Old Data (for 0-overhead and packing)
  template <typename T, typename E>
  struct EndianessConverter {
    T value;
    
    // access wrappers
    inline void operator= (T v) { value = ByteSwap<NativeEndianTraits, E, T>::Swap (v); }
    inline T operator* () const { return ByteSwap<E,NativeEndianTraits, T>::Swap (value); }
    inline operator T () const { return ByteSwap<E,NativeEndianTraits, T>::Swap (value); }
  };
  
}

#endif // LOWLEVEL__ENDIANESS_HH__