--kolokwium 2, grupa D1 (AN)
--Utw�rz tabele pracownik(id_pracownik, nazwisko, imie, pesel), gdzie: 
--id_pracownik - automatycznie nadawany, niepusty numer pracownika, klucz g��wny,
--nazwisko - niepusty �a�cuch znak�w zmiennej d�ugo�ci od 3 do 20 znak�w,
--imie - niepusty �a�cuch znak�w zmiennej wielko�ci od 3 do 20 znak�w
-- pesel  dok�adnie 11 znak�w
SET DATEFORMAT ymd;
--
CREATE TABLE pracownik(
id_pracownik INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
nazwisko VARCHAR(30) NOT NULL CHECK(LEN(nazwisko)>=3),
imie VARCHAR(30) NOT NULL CHECK(LEN(imie)>=3),
pesel CHAR(11)
);

-- tabel� firma(id_firma,nazwa, typ, )
--id_firma -automatycznie nadawany, niepusty numer firmy, klucz g��wny,
--nazwa - niepusty �a�cuch znak�w zmiennej wielko�ci od 3 do 20 znak�w
-- typ - niepusty �a�cuch znak�w zmiennej d�ugo�ci od 3 do 20 znak�w,

CREATE TABLE firma(
id_firma INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
nazwa VARCHAR(20) NOT NULL CHECK(LEN(nazwa)>=3),
typ VARCHAR(20) NOT NULL CHECK(LEN(typ)>=3)
);



--oraz tabel� wyplaty ( id_wyplaty, id_pracownik,id_firma,data, kwota), gdzie:
--id_wyplaty - niepusty klucz g��wny, warto�ci nadawane automatycznie,
--id_pracownik - niepusty klucz obcy powi�zany z kolumn� id_pracowniki tabeli pracownik,
--id_firma - niepusty klucz obcy powi�zany z kolumn� id_firma tabeli firma,
--data- data wyplaty
--kwota -kwota wyp�aty

CREATE TABLE wyplaty(
id_wyplaty INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
id_pracownik INT NOT NULL FOREIGN KEY REFERENCES pracownik(id_pracownik),
id_firma INT NOT NULL FOREIGN KEY REFERENCES firma(id_firma),
data DATE,
kwota MONEY
);
--Dodaj klika przyk�adowych rekord�w do ka�dej z tabel
--Rozwi�zanie [3pkt]:
--prac
INSERT INTO pracownik VALUES('Szewczak','Aleksander','97043012891');
INSERT INTO pracownik VALUES('Roman','Adam','97043012894');
INSERT INTO pracownik VALUES('Stasiak','Kamil','97043012896');
--firma
INSERT INTO firma VALUES('Wimest','uslugi');
INSERT INTO firma VALUES('Inprox','informatyka');
INSERT INTO firma VALUES('Sii','informatyka');
--wyplaty
INSERT INTO wyplaty VALUES(1,1,'2015-05-05',2000);
INSERT INTO wyplaty VALUES(2,2,'2016-06-06',3000);
INSERT INTO wyplaty VALUES(3,3,'2017-07-07',4000);

--selecty
SELECT * FROM pracownik;
SELECT * FROM firma;
SELECT * FROM wyplaty;
GO

--Utw�rz widok raport(id_pracownik ,nazwisko,pesel, suma_pieniedzy), gdzie 
--id_pracownik, nazwisko,pesel  to kolumny z tabeli pracownik
--suma_pieniedzy - ��czna suma wyp�at danego pracownika z tabeli wyplaty
--Rozwi�zanie +test rozwi�zania[1 pkt]

CREATE VIEW raport AS
SELECT p.id_pracownik,p.nazwisko,p.pesel,SUM(w.kwota) AS suma_pieniedzy
FROM pracownik p JOIN wyplaty w ON p.id_pracownik=w.id_pracownik
GROUP BY p.id_pracownik,p.nazwisko,p.pesel
GO
--DROP VIEW raport

--testy
SELECT * FROM raport;
GO

--Utw�rz wyzwalacz, kt�ry reaguje na modyfikacje danych pracownik�w  w widoku raport - dane maj� by� zmodyfikowane tak�e w tabeli pracownik.
--Rozwi�zanie +test rozwi�zania [3 pkt]
CREATE TRIGGER modyfik_trig ON raport
INSTEAD OF UPDATE
AS
DECLARE modyfik_kursor CURSOR
FOR SELECT nazwisko,pesel,id_pracownik FROM INSERTED
DECLARE @nazwisko VARCHAR(20), @pesel CHAR(11), @id_pracownik INT
OPEN modyfik_kursor
FETCH NEXT FROM modyfik_kursor INTO @nazwisko, @pesel, @id_pracownik
WHILE @@FETCH_STATUS=0
	BEGIN
		UPDATE pracownik
		SET nazwisko=@nazwisko,pesel=@pesel
		WHERE id_pracownik=@id_pracownik
	FETCH NEXT FROM modyfik_kursor INTO @nazwisko, @pesel, @id_pracownik
END
CLOSE modyfik_kursor
DEALLOCATE modyfik_kursor

--DROP TRIGGER modyfik_trig

--testy
select * from raport;
update raport
set pesel='97043012811'
where id_pracownik=1
select * from pracownik;

--Do tabeli pracownik dodaj kolumn� usuni�ty, z domy�ln� warto�ci� 0,
--Napisa� wyzwalacz, kt�ry zamiast usun�� fizycznie rekord z tabeli pracownik zmieni 
--warto�� kolumny usuni�ty z 0 na 1,
--Rozwi�zanie + test rozwi�zania [3 pkt]:
ALTER TABLE pracownik
ADD usuniety BIT NOT NULL DEFAULT 0
GO

SELECT * FROM pracownik;
GO

CREATE TRIGGER trig_usun ON pracownik
INSTEAD OF DELETE
AS
DECLARE kursor_usun CURSOR
FOR SELECT id_pracownik FROM DELETED
DECLARE @id_pracownik INT
OPEN kursor_usun
FETCH NEXT FROM kursor_usun INTO @id_pracownik
WHILE @@FETCH_STATUS=0
	BEGIN
		UPDATE pracownik
		SET usuniety=1
		WHERE id_pracownik=@id_pracownik
		FETCH NEXT FROM kursor_usun INTO @id_pracownik
END
CLOSE kursor_usun
DEALLOCATE kursor_usun

--DROP TRIGGER trig_usun
SELECT * FROM pracownik;
DELETE FROM pracownik WHERE id_pracownik=1
SELECT * FROM pracownik;

--Do tabeli pracownik  dodaj kolumn� nr_tel przechowuj�c� informacj� o numerze telefonu (11 lub 12 znakow)
--Rozwi�zanie [1pkt]
ALTER TABLE pracownik
ADD nr_tel VARCHAR(12) CHECK(LEN(nr_tel)>=11)
GO
--testy
SELECT * FROM pracownik;
GO
--Napisz funkcj� pomocnicz�, kt�ra sprawdza czy numer telefonu jest w poprawnym formacie 
--w formacie xxx-xxx-xxx lub xx-xxx-xx-xx, gdzie x to cyfry (dla okre�lonej d�ugo�ci sprawd� czy numer sklada si� z cyfr i znak�w - na odpowiedniej pozycji)
--Funkcja powinna zwraca� 1 gdy format numeru si� zgadza, 0  W przeciwnym wypadku.
--Rozwi�zanie + test rozwi�zania [2 pkt]

CREATE FUNCTION spr_tel(@nr_tel VARCHAR(12))
RETURNS INT
BEGIN
	IF (@nr_tel LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]')
	BEGIN
		RETURN 1
	END
	ELSE IF (@nr_tel LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]')
	BEGIN
		RETURN 1
	END
	RETURN 0
END
GO
--testy
--poprawny
SELECT dbo.spr_tel('666-296-418');
--niepoprawny
SELECT dbo.spr_tel('666296-418');
GO


--Napisz wyzwalacz, wykorzystuj�cy powy�sz� funkcj�, kt�ry nowym klientom zamieni niepoprawny numer telefonu na null
--Rozwi�zanie + test rozwi�zania [2 pkt]

CREATE TRIGGER zmien_nr ON pracownik
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @id_pracownik INT
	SELECT @id_pracownik=id_pracownik FROM INSERTED
	DECLARE @nr_tel VARCHAR(12)
	SELECT @nr_tel=nr_tel FROM INSERTED
	IF (dbo.spr_tel(@nr_tel)=0)
		BEGIN
		UPDATE pracownik
		SET nr_tel = null
		WHERE id_pracownik=@id_pracownik
		END
END

--testy
SELECT * FROM pracownik;
UPDATE pracownik
SET nr_tel='666-2964-1-8'
WHERE id_pracownik=1
-- zmienia na null
INSERT pracownik VALUES('Mich','Adam','97043012849',0,'654-3346-9-7')
SELECT * FROM pracownik;