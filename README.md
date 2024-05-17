# Ogólne
W ramach przedmiotu Zawansowane architektury baz danych stworzony został system bazodanowy do obsługi szkoły (dziennik elektoryniczny) w realcyjnej bazie danych MySQL. Do celów prezentacyjnych zaimplementowany została również aplikacji webowa w języku TypeScript z wykorzystaniem frameworka React.

Struktura bazy danych przedstawiona została za pomocą diagramu ERD w pliku newSchema.png.

# Uruchomienie bazy
W celu uruchomienia systemu bazodanowego należy wykonać komendę `docker-compose up` w katalogu z plikiem docker-compose.yml.

# Uruchomienie aplikacji do prezentacji
W celu uruchomienia aplikacji webowej nalezy wykonac kmende `npm run dev` w katalogu school-frontend.

# PROCEDURY
1. Wykorzystana w trigerze nr 1, 4 - sprawdza czy dana klasa zakonczyla juz swoja edukacje
2. Wykorzystana w trigerze nr 2 - sprawdza czy dla danej klasy mozna dodac lekcje w danym czasie
3. Wyliczenie średniej ocen klasy
4. Wyznaczenie planu lekcji dla klasy
5. Wyliczenie średniej ocen ucznia
6. Wyliczenie sredniej ocen ucznia dla poszczegolnych przedmiotow

# FUNKCJE
1. Wykorzystana w trigerze nr 6, 7, 8, 9 - sprawdza czy uzytkownik jest studentem
2. Wykorzystana w trigerze nr 12, 13 - sprawdza czy uzytkownik jest nauczycielem i czy nie ma juz wychowastwa
3. Wykorzystana w trigerze nr 14, 15 - wyznacza liczbe uczniow w klasie

# Trigery
1. Przed dodaniem ucznia do klasy sprawdzane jest to czy klasa zakoncyzla juz swoja edukacje - jesli tak to rzucamy blad - procedura nr 1
2. Przed dodaniem nowej lekcji do planu zajęć sprawdzamy czy nowy wpis nie nachodzi czasowo na inne zajęcia
3. Po dodaniu nowej klasy automatycznie wyznaczany jest rok ukonczenia szkoly
4. W przypadku modyfikacji klasy studenta sprawdzane jest to czy napewno ta klasa nie zakonczyla juz edukacji.
5. W przypadku modyfikacji klasy automatycznie wyznaczany jest rok ukonczenia klasy
6. Przed dodaniem oceny sprawdzamy czy user dodajcy ocene na pewno nie jest uczniem.
7. Przed modyfikacja oceny sprawdzamy czy user dodajcy ocene na pewno nie jest uczniem.
8. Przed dodaniem oceny sprawdzamy czy user otrzymujacy ocene na pewno jest uczniem.
9. Przed aktualizacją oceny sprawdzamy czy user otrzymujacy ocene na pewno jest uczniem.
10. Przed aktualizacją oceny sprawdzamy, czy nauczyciel wystawiający ocenę na pewno naucza ucznia otrzymującego ocenę przedmiotu z którego ocena jest wystawiana.
11. Przed aktualizacją oceny sprawdzamy, czy nauczyciel wystawiający ocenę na pewno naucza ucznia otrzymującego ocenę przedmiotu z którego ocena jest wystawiana.
12. Przed dodaniem klasy sprawdzany jest wychowawca - czy na pewno jest nauczycielem i czy nie jest juz wychowawca
13. Przed updatem klasy - zmiana wychowawcy - sprawdzany jest czy na pewno jest nauczycielem i czy nie jest juz wychowawca
14. Przed dodaniem ucznia do klasy sprawdzane jest czy limit liczby uczniow w klasie nie zostal przekroczony.
15. Przed updatem ucznia - zmiany klasy sprawdzane jest czy limit liczby uczniow w klasie nie zostal przekroczony.

# Widoki
1. Lista wszystkich ocen ucznia
2. Lista ocen klasy z danego przedmiotu (dziennik)
3. Plan lekcji dla danego użytkownika
4. Top 10 uczniów z najlepszą w szkole średnią łączną ze swoich przedmiotów
5. TOP 10 klas z najlepszą łączną średnią ocen w szkole
6. Lista uczniów klasy, którym wychodzą zagrożenia, z listą przedmiotów zagrożonych
7. Lista uczniów kwalifikujących sie do stypendium/świadectwa z paskiem za średnią ocen
8. Lista klas które uczy dany nauczyciel, z przedmiotami których tam uczy
9. Lista klas z wychowawcami i wyliczonym rokiem (1,2,3 itp. klasa)
10. Lista wszystkich ocen z wartosciami i nauczyicelem wystawiajacym

