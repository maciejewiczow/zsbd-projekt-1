create table if not exists szkola.GradeValue
(
    GradeValueID  int auto_increment
        primary key,
    NumericValue  float       not null,
    SymbolicValue varchar(3)  not null,
    Name          varchar(25) not null,
    ShortName     varchar(7)  not null,
    constraint GradeValue_SymbolicValue_uindex
        unique (SymbolicValue)
)
    comment 'Używane przez szkołę wartości ocen';

create table if not exists szkola.Permission
(
    PermissionID int auto_increment
        primary key,
    Name         varchar(40)  not null,
    Description  varchar(300) null
)
    comment 'Lista uprawnień dostępnych w systemie';

create table if not exists szkola.Profile
(
    ProfileID int auto_increment
        primary key,
    FullName  varchar(40) null,
    ShortName varchar(10) not null
)
    comment 'Profile klas równoległych obecnych w szkole';

create table if not exists szkola.Subject
(
    SubjectID int auto_increment
        primary key,
    Name      varchar(200) not null,
    ShortName varchar(20)  not null
)
    comment 'Nazwy i skróty przedmiotów uczonych w szkole';

create table if not exists szkola.UserRole
(
    UserRoleID int auto_increment
        primary key,
    RoleName   varchar(100) not null
)
    comment 'Role użytkowników';

create table if not exists szkola.RolePermission
(
    UserRoleID       int not null,
    PermissionID     int not null,
    RolePermissionID int auto_increment
        primary key,
    constraint RolePermission_UserRoleID_PermissionID_uindex
        unique (UserRoleID, PermissionID),
    constraint RolePermission_Permission_PermissionID_fk
        foreign key (PermissionID) references szkola.Permission (PermissionID),
    constraint RolePermission_UserRole_UserRoleID_fk
        foreign key (UserRoleID) references szkola.UserRole (UserRoleID)
)
    comment 'Uprawnienia przypadające dla danej roli';

create table if not exists szkola.User
(
    UserID       int auto_increment
        primary key,
    Email        varchar(100) not null,
    PasswordHash binary(60)   not null,
    Name         varchar(120) null,
    Surname      varchar(120) null,
    Address      varchar(200) null,
    UserRoleID   int          not null,
    PESEL        char(11)     not null,
    constraint User_Email_uindex
        unique (Email),
    constraint User_PESEL_uindex
        unique (PESEL),
    constraint User_UserRole_UserRoleID_fk
        foreign key (UserRoleID) references szkola.UserRole (UserRoleID)
)
    comment 'Użytkownicy systemu';

create table if not exists szkola.Class
(
    ClassID          int auto_increment
        primary key,
    StartYear        int not null,
    GraduationYear   int not null,
    Preceptor_UserID int not null,
    ProfileID        int not null,
    constraint Class_ProfileID_StartYear_uindex
        unique (ProfileID, StartYear),
    constraint ClassYear_User_UserID_fk
        foreign key (Preceptor_UserID) references szkola.User (UserID),
    constraint Class_Profile_ProfileID_fk
        foreign key (ProfileID) references szkola.Profile (ProfileID)
)
    comment 'Klasy uczące się w szkole';

create table if not exists szkola.ClassSubjectTeacher
(
    SubjectID      int not null,
    ClassID        int not null,
    Teacher_UserID int not null,
    primary key (SubjectID, ClassID),
    constraint ClassSubjectTeacher_temp_Class_ClassID_fk
        foreign key (ClassID) references szkola.Class (ClassID),
    constraint ClassSubjectTeacher_temp_Subject_SubjectID_fk
        foreign key (SubjectID) references szkola.Subject (SubjectID),
    constraint ClassSubjectTeacher_temp_User_UserID_fk
        foreign key (Teacher_UserID) references szkola.User (UserID)
)
	comment 'Informacja o tym, który nauczyciel uczy danego przedmiotu którą klasę';

create table if not exists szkola.Grade
(
    GradeID       int auto_increment
        primary key,
    GradeValueID  int                                 not null,
    SubjectID     int                                 not null,
    Issuer_UserID int                                 not null,
    Owner_UserID  int                                 not null,
    Weight        float     default 1                 not null,
    IssuedAt      timestamp default CURRENT_TIMESTAMP null,
    constraint Grade_GradeValue_GradeValueID_fk
        foreign key (GradeValueID) references szkola.GradeValue (GradeValueID),
    constraint Grade_Subject_SubjectID_fk
        foreign key (SubjectID) references szkola.Subject (SubjectID),
    constraint Grade_User_UserID_fk
        foreign key (Issuer_UserID) references szkola.User (UserID),
    constraint Grade_User_UserID_fk_2
        foreign key (Owner_UserID) references szkola.User (UserID)
)
    comment 'Oceny';

create table if not exists szkola.Student
(
    UserID  int not null,
    ClassID int not null,
    primary key (UserID),
    constraint Student_Class_ClassID_fk
        foreign key (ClassID) references szkola.Class (ClassID),
    constraint Student_User_UserID_fk
        foreign key (UserID) references szkola.User (UserID)
            on update cascade on delete cascade
)
    comment 'Przynależność do danej klasy użytkownika z rolą Student';

create table if not exists szkola.Timetable
(
    TimetableID               int auto_increment
        primary key,
    ReplacementTeacher_UserID int  null,
    TimeStart                 time not null,
    TimeEnd                   time not null,
    DayNumber                 int  not null,
    ClassID                   int  not null,
    SubjectID                 int  null,
    constraint Timetable_ClassSubjectTeacher_SubjectID_ClassID_fk
        foreign key (SubjectID, ClassID) references szkola.ClassSubjectTeacher (SubjectID, ClassID),
    constraint Timetable_User_UserID_fk
        foreign key (ReplacementTeacher_UserID) references szkola.User (UserID)
)
    comment 'Plan lekcji różnych klas';


