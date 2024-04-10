INSERT INTO szkola.UserRole
    (RoleName)
VALUES
    ('Student'),
    ('Teacher'),
    ('Administrator'),
    ('Tester');

INSERT INTO szkola.GradeValue
    (NumericValue, SymbolicValue, Name)
VALUES
    (0, '0', 'brak'),
    (1, '1', 'niedostateczny'),
    (1.5, '-1', 'minus niedostateczny'),
    (1.5, '+1', 'plus niedostateczny'),
    (1.5, '-2', 'minus dostateczny'),
    (2, '2', 'dostateczny'),
    (2.5, '+2', 'plus dostateczny'),
    (2.5, '-3', 'minus dopuszczający'),
    (3, '3', 'dopuszczający'),
    (3.5, '+3', 'plus dopuszczający'),
    (3.5, '-4', 'minus dobry'),
    (4, '4', 'dobry'),
    (4.5, '+4', 'plus dobry'),
    (4.5, '-5', 'minus bardzo dobry'),
    (5, '5', 'bardzo dobry'),
    (5.5, '+5', 'plus bardzo dobry'),
    (5.5, '-6', 'minus celujący'),
    (6, '6', 'celujący');

INSERT INTO szkola.Permission
    (Name, Description)
VALUES
    ('ALL', 'Wszystkie uprawnienia'),
    ('ADD_USER', 'Dodawanie nowych użytkowników'),
    ('MOD_USER_SELF', 'Modyfikowanie własnych danych'),
    ('MOD_USER', 'Modyfikowanie danych użytkowników'),
    ('DEL_USER', 'Usuwanie użytkowników'),
    ('ADD_OWNED_CLASS_GRADE', 'Dodanie oceny z porzedmiotu, który prowadzi się z daną klasą'),
    ('MOD_OWNED_GRADE', 'Modyfikacja ocen wystawionych przez siebie'),
    ('DEL_OWNED_GRADE', 'Usuwanie ocen wystawionych przez siebie'),
    ('ADD_GRADE', 'Dodawanie ocen'),
    ('MOD_GRADE', 'Modufikacja ocen'),
    ('DEL_GRADE', 'Usuwanie ocen');

INSERT INTO szkola.RolePermission
    (UserRoleID, PermissionID)
VALUES
    (1, 2), -- Student - modyfikacja własnych danych
    (2, 6),
    (2, 7),
    (2, 8),
    (3, 1),
    (4, 1);
