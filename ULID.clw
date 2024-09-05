    member    
    
    map
        include( 'ULID.inc' ),once
    end !* end *                
    map
        module('Windows.DLL')
            GetSystemTime(*SystemTime),pascal,raw
            GetSystemTimeAsFileTime(*FileTime),pascal,raw
        end         
        include( 'i64.inc' ),once        
        GetSystemTimeAsUnixTime( *decimal _timeStamp )
    end !* end *
    
FileTime            group,type
dwLowDateTime           ulong
dwHighDateTime          ulong
                    end !* group *
    
SystemTime          group,type              !System time struct
wYear                   UShort
wMonth                  UShort
wDayOfWeek              UShort
wDay                    UShort
wHour                   UShort
wMinute                 UShort
wSecond                 UShort
wMilliseconds           UShort
                    end !* group *

UnixStartTime       equate( 61730 ) ! equal to "date( 01, 01, 1970 )"
UUID_SIZE           equate(16)
GMT                 long( 0 )
lookup_table_upr    cstring('000102030405060708090A0B0C0D0E0F' & |
                            '101112131415161718191A1B1C1D1E1F' & |
                            '202122232425262728292A2B2C2D2E2F' & |
                            '303132333435363738393A3B3C3D3E3F' & |
                            '404142434445464748494A4B4C4D4E4F' & |
                            '505152535455565758595A5B5C5D5E5F' & |
                            '606162636465666768696A6B6C6D6E6F' & |
                            '707172737475767778797A7B7C7D7E7F' & |
                            '808182838485868788898A8B8C8D8E8F' & |
                            '909192939495969798999A9B9C9D9E9F' & |
                            'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF' & |
                            'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF' & |
                            'C0C1C2C3C4C5C6C7C8C9CACBCCCDCEDF' & |
                            'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF' & |
                            'E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF' & |
                            'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF' )
                            
lookup_table_lwr    cstring('000102030405060708090a0b0c0d0e0f' & |
                            '101112131415161718191a1b1c1d1e1f' & |
                            '202122232425262728292a2b2c2d2e2f' & |
                            '303132333435363738393a3b3c3d3e3f' & |
                            '404142434445464748494a4b4c4d4e4f' & |
                            '505152535455565758595a5b5c5d5e5f' & |
                            '606162636465666768696a6b6c6d6e6f' & |
                            '707172737475767778797a7b7c7d7e7f' & |
                            '808182838485868788898a8b8c8d8e8f' & |
                            '909192939495969798999a9b9c9d9e9f' & |
                            'a0a1a2a3a4a5a6a7a8a9aaabacadaeaf' & |
                            'b0b1b2b3b4b5b6b7b8b9babbbcbdbebf' & |
                            'c0c1c2c3c4c5c6c7c8c9cacbcccdcedf' & |
                            'd0d1d2d3d4d5d6d7d8d9dadbdcdddedf' & |
                            'e0e1e2e3e4e5e6e7e8e9eaebecedeeef' & |
                            'f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff' )
                            
SetGMT          procedure( long _gmt ) 
    code
    GMT = _gmt

NewUUIDv7       procedure( BOOL flag=0 )!,string
uuid            byte,dim(UUID_SIZE)
sUUID           cstring(37)
xUUID           cstring(37)
lookup_table    &cstring,auto
idx             long
lck             long
i               long
    code
    NewUUIDv7Array( uuid )
    if flag
        lookup_table &= lookup_table_lwr        
    else
        lookup_table &= lookup_table_upr        
    end !* if *    
    loop i = 1 to UUID_SIZE
        idx = (i-1) * 2 + 1
        lck = uuid[i] * 2 + 1
        sUUID[ idx ]     = lookup_table[ lck ]
        sUUID[ idx + 1 ] = lookup_table[ lck + 1 ]
    end !* loop *
    sUUID[ UUID_SIZE*2 + 1 ] = '<0>'
    
    xUUID = sUUID[01:08] &'-'& sUUID[09:12] &'-'& sUUID[13:16] &'-'& sUUID[17:20] &'-'& sUUID[21:32+1]

	return xUUID
	
GetSystemTimeAsUnixTime     procedure( *decimal _timeStamp )
UNIX_TIME_START     equate(019DB1DED53E8000H)       ! January 1, 1970 (start of Unix epoch) in "ticks"
TICKS_PER_SECOND    equate(10000000)                ! a tick is 100ns

ft                  like(FileTime)
i64                 like(UInt64)
li                  decimal(31)
UTS                 decimal(31)
    code
    ! Get the number of seconds since January 1, 1970 12:00am UTC
    ! Code released into public domain; no attribution required.

    GetSystemTimeAsFileTime( ft );                    ! returns ticks in UTC

    ! Copy the low and high parts of FILETIME into a LARGE_INTEGER
    ! This is so we can access the full 64-bits as an Int64 without causing an alignment fault
    i64.lo  = ft.dwLowDateTime
    i64.hi  = ft.dwHighDateTime
     
    ! Convert ticks since 1/1/1970 into seconds
    i64ToDecimal( li, i64 )
    UTS = 116444736000000000
    !message( 'LO:' & i64.lo & ' HI:' & i64.hi & '-->' & li, UTS)
    
    _timeStamp = (li - UTS) / TICKS_PER_SECOND;

!NewUUIDv7Array  procedure( *byte[] _ulid )
!days_since_1970 long
!iToday          decimal(31)
!iClock          decimal(31)
!timeStamp       decimal(31)
!SysTime         like(SystemTime)
!i64             like(Int64)
!uuid8           byte,dim(8),over(i64)
!i               long
!    code
!    if maximum( _ulid, 1 ) >= UUID_SIZE
!        GetSystemTime( SysTime )
!        iToday = date( SysTime.wMonth, SysTime.wDay, SysTime.wYear )
!        days_since_1970 = iToday - UnixStartTime
!        
!        iClock = (((SysTime.wHour+GMT) * 3600) + (SysTime.wMinute * 60) + SysTime.wSecond) + SysTime.wMilliseconds
!        timestamp = ((days_since_1970 * 86400) + iClock) * 1000 + SysTime.wMilliseconds
!        
!        i64FromDecimal( i64, timestamp )
!        _ulid[ 1 ] = uuid8[ 6 ]
!        _ulid[ 2 ] = uuid8[ 5 ]
!        _ulid[ 3 ] = uuid8[ 4 ]
!        _ulid[ 4 ] = uuid8[ 3 ]
!        _ulid[ 5 ] = uuid8[ 2 ]
!        _ulid[ 6 ] = uuid8[ 1 ]
!       
!        loop i = 7 to UUID_SIZE
!            _ulid[i] = random( 0, 255 )
!        end !* loop *        
!
!        ! Set version (7) and variant bits (2 MSB as 01)
!        _ulid[7] = bor( band(_ulid[7], 00FH), bshift(7, 4) )
!        _ulid[9] = bor( band(_ulid[9], 03FH), 080H )
!    end !* if *
    
NewUUIDv7Array  procedure( *byte[] _ulid )
timeStamp       decimal(31)
i64             like(Int64)
uuid8           byte,dim(8),over(i64)
i               long
    code
    if maximum( _ulid, 1 ) >= UUID_SIZE
        GetSystemTimeAsUnixTime( timeStamp )
        
        i64FromDecimal( i64, timeStamp )
        _ulid[ 1 ] = uuid8[ 6 ]
        _ulid[ 2 ] = uuid8[ 5 ]
        _ulid[ 3 ] = uuid8[ 4 ]
        _ulid[ 4 ] = uuid8[ 3 ]
        _ulid[ 5 ] = uuid8[ 2 ]
        _ulid[ 6 ] = uuid8[ 1 ]
       
        loop i = 7 to UUID_SIZE
            _ulid[i] = random( 0, 255 )
        end !* loop *        

        ! Set version (7) and variant bits (2 MSB as 01)
        _ulid[7] = bor( band(_ulid[7], 00FH), bshift(7, 4) )
        _ulid[9] = bor( band(_ulid[9], 03FH), 080H )
    end !* if *    
    
!* end *