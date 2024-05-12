W ramach przedmiotu Zawansowane architektury baz danych stworzony został system bazodanowy do obsługi szkoły (dziennik elektoryniczny) w realcyjnej bazie danych MongoDB. Do celów prezentacyjnych zaimplementowany została również aplikacji webowa w języku TypeScript z wykorzystaniem frameworka React.

# PROCEDURY
1. Wykorzystana w trigerze nr 1, 4 - sprawdza czy dana klasa zakonczyla juz swoja edukacje
2. Wykorzystana w trigerze nr 2 - sprawdza czy dla danej klasy mozna dodac lekcje w danym czasie

# FUNKCJE
1. Wykorzystana w trigerze nr 6, 7, 8, 9 - sprawdza czy uzytkownik jest studentem
2. Wykorzystana w trigerze nr 12 - sprawdza czy uzytkownik jest nauczycielem i czy nie ma juz wychowastwa

# Trigery
1. Przed dodaniem ucznia do klasy sprawdzane jest to czy klasa zakoncyzla juz swoja edukacje - jesli tak to rzucamy blad - procedura nr 1
2. Przed dodaniem nowej lekcji do planu zajęć sprawdzamy czy nowy wpis nie nachodzi czasowo na inne zajęcia
3. Po dodaniu nowej klasy automatycznie wyznaczany jest rok ukonczenia szkoly
4. W przypadku modyfikacji klasy studenta sprawdzane jest to czy napewno ta klasa nie zakonczyla juz edukacji.
5. W przypadku modyfikacji klasy automatycznie wyznaczany jest rok ukonczenia klasy
6 i 7. Przed dodaniem/aktualizacją oceny sprawdzamy czy user dodajcy ocene na pewno nie jest uczniem.
8 i 9. Przed dodaniem/aktualizacją oceny sprawdzamy czy user otrzymujacy ocene na pewno jest uczniem.
10 i 11. Przed dodaniem/aktualizacją oceny sprawdzamy, czy nauczyciel wystawiający ocenę na pewno naucza ucznia otrzymującego ocenę przedmiotu z którego ocena jest wystawiana.

# Widoki
1. Lista wszystkich ocen ucznia
2. Lista ocen klasy z danego przedmiotu (dziennik)
3. Plan lekcji dla danego użytkownika
4. Top 10 uczniów z najlepszą w szkole średnią łączną ze swoich przedmiotów
5. TOP 10 klas z najlepszą łączną średnią ocen w szkole
6. Lista uczniów klasy, którym wychodzą zagrożenia, z listą przedmiotów zagrożonych
7. Lista uczniów kwalifikujących sie do stypendium/świadectwa z paskiem za średnią ocen
8. Lista klas które uczy dany nauczyciel, z przedmiotami których tam uczy

# Uwagi
Usuniecie tabeli student, dodanie classID do usera (null jesli nie student) - zrobione
Rola wychowawca w userze sprawdzana przy dodwaniu klasy i jej wychowawca - zrobione
Procedura do wyznaczania liczby osob w klasie i triger sprawdzajacy czy nie ma maksa klasa (np. 40 osob) - zrobione
