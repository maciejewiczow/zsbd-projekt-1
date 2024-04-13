# PROCEDURY
1. Wykorzystana w trigerze nr 1 - sprawdza czy dana klasa zakonczyla juz swoja edukacje
2. Wykorzystana w trigerze nr 2 - sprawdza czy dla danej klasy mozna dodac lekcje w danym czasie

# FUNKCJE
1. Wykorzystana w trigerze nr 4, 5 - sprawdza czy uzytkownik jest studentem

# Trigery
1. Przed dodaniem ucznia do klasy sprawdzane jest to czy klasa zakoncyzla juz swoja edukacje - jesli tak to rzucamy blad - procedura nr 1
2. Przed dodaniem nowej lekcji do planu zajęć sprawdzamy czy nowy wpis nie nachodzi czasowo na inne zajęcia
3. Po dodaniu nowej klasy automatycznie wyznaczany jest rok ukonczenia szkoly
4. Przed dodaniem/aktualizacją oceny sprawdzamy czy user otrzymujacy ocene na pewno jest uczniem.
5. Przed dodaniem/aktualizacją oceny sprawdzamy czy user dodajcy ocene na pewno nie jest uczniem.
6. Przed dodaniem/aktualizacją oceny sprawdzamy, czy nauczyciel wystawiający ocenę na pewno naucza ucznia otrzymującego ocenę przedmiotu z którego ocena jest wystawiana.

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
Usuniecie tabeli student, dodanie classID do usera (null jesli nie student)
Rola wychowawca w userze sprawdzana przy dodwaniu klasy i jej wychowawca
Procedura do wyznaczania liczby osob w klasie i triger sprawdzajacy czy nie ma maksa klasa (np. 30 osob)