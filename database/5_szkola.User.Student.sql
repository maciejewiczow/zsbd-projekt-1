UPDATE szkola.User SET ClassID=FLOOR( 1 + RAND( ) *24 )
ORDER BY UserID ASC
LIMIT 700;