! -------------------------------------------------------------------------
! Universally Unique Lexicographically Sortable Identifier
!
! Usage:
! Inside Global Map:
!
!       include( 'ULID.inc' ),once
!
! Gustavo Saracca, 2024.
! -------------------------------------------------------------------------

    module( 'ULID.CLW' )
        SetGMT( long _gmt )       
        NewUUIDv7Array( *byte[] _ulid )
        NewUUIDv7( BOOL flag=0 ),string
    end !* module *
    
COMPILE('Link', _ABCLinkMode_)
    PRAGMA('compile(ULID.CLW)')
!Link