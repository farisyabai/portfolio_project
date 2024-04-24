-- Cleaning data in SQL

-- Standardize data format

SELECT 
	SaleDate, 
    CONVERT(SaleDate, DATE)
FROM housing_data.nashvillehousing;

ALTER TABLE housing_data.nashvillehousing
ADD SaleDateConverted DATE;

UPDATE housing_data.nashvillehousing
SET SaleDateConverted = CONVERT(SaleDate, DATE);


ALTER TABLE nashvillehousing
MODIFY Acreage DOUBLE;


SELECT REPLACE(LandValue, SUBSTR(LandValue, -2, 2), '')
FROM nashvillehousing;

UPDATE nashvillehousing
SET LandValue = REPLACE(LandValue, SUBSTR(LandValue, -2, 2), '');

UPDATE nashvillehousing
SET LandValue = NULL
WHERE LandValue = '';

ALTER TABLE nashvillehousing
MODIFY LandValue DOUBLE;


ALTER TABLE nashvillehousing
MODIFY COLUMN OwnerName VARCHAR(255);


SELECT REPLACE(YearBuilt, SUBSTR(YearBuilt, -2, 2), '')
FROM nashvillehousing;

UPDATE nashvillehousing
SET YearBuilt = REPLACE(YearBuilt, SUBSTR(YearBuilt, -2, 2), '');

ALTER TABLE nashvillehousing
MODIFY COLUMN YearBuilt CHAR(4);


ALTER TABLE nashvillehousing
MODIFY COLUMN LandUse VARCHAR(50);


ALTER TABLE nashvillehousing
MODIFY COLUMN LegalReference VARCHAR(50);


UPDATE nashvillehousing
SET HalfBath = NULL
WHERE HalfBath= '';

ALTER TABLE nashvillehousing
MODIFY HalfBath TINYINT;


-- Populate PropertyAddress / input missing values

SELECT 
	a.PropertyAddress,
    a.ParcelID,
    b.PropertyAddress,
    b.ParcelID
FROM housing_data.nashvillehousing a
JOIN housing_data.nashvillehousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID;


-- Breaking out address into individual column (address, city, state)

SELECT SUBSTRING_INDEX(nashvillehousing.PropertyAddress, ',', -1)
FROM nashvillehousing;

SELECT *
FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN Property_City;

ALTER TABLE nashvillehousing
ADD Property_City VARCHAR(255);

UPDATE nashvillehousing
SET Property_City = SUBSTRING_INDEX(nashvillehousing.PropertyAddress, ',', -1);

SELECT SUBSTRING_INDEX(nashvillehousing.PropertyAddress, ',', 1)
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD Property_Address VARCHAR(255);

UPDATE nashvillehousing
SET Property_Address = SUBSTRING_INDEX(nashvillehousing.PropertyAddress, ',', 1);

SELECT OwnerAddress
FROM nashvillehousing;

SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1)
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD Owner_Address VARCHAR(50);

UPDATE nashvillehousing
SET Owner_Address = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashvillehousing
ADD Owner_State VARCHAR(50);

UPDATE nashvillehousing
SET Owner_State = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT SUBSTRING_INDEX(
SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD Owner_City VARCHAR(50);

UPDATE nashvillehousing
SET Owner_City = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

-- Remove Distinct value from SoldAsVacant (change Y and N to Yes and No)

SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY 1
ORDER BY 2;

SELECT
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant =	CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
					END;

-- Remove Duplicates

SELECT *
FROM nashvillehousing
WHERE UniqueID IN (
	SELECT UniqueID
	FROM (
		SELECT *, 
			ROW_NUMBER() OVER (
					PARTITION BY 
						ParcelID, 
						LandUse, 
						SalePrice, 
						LegalReference, 
						SoldAsVacant, 
						OwnerName, 
						OwnerAddress, 
						Acreage, 
						TaxDistrict, 
						LandValue, 
						BuildingValue, 
						TotalValue, 
						YearBuilt, 
						Bedrooms, 
						FullBath, 
						HalfBath, 
						SaleDateConverted, 
						Property_City, 
						Property_Address, 
						Owner_Address, 
						Owner_State, 
						Owner_City 
						)  AS row_num
		FROM nashvillehousing ) AS nh
	WHERE row_num > 1 );

DELETE
FROM nashvillehousing
WHERE UniqueID IN (
	SELECT UniqueID
	FROM (
		SELECT *, 
			ROW_NUMBER() OVER (
					PARTITION BY 
						ParcelID, 
						LandUse, 
						SalePrice, 
						LegalReference, 
						SoldAsVacant, 
						OwnerName, 
						OwnerAddress, 
						Acreage, 
						TaxDistrict, 
						LandValue, 
						BuildingValue, 
						TotalValue, 
						YearBuilt, 
						Bedrooms, 
						FullBath, 
						HalfBath, 
						SaleDateConverted, 
						Property_City, 
						Property_Address, 
						Owner_Address, 
						Owner_State, 
						Owner_City 
						)  AS row_num
		FROM nashvillehousing ) AS nh
	WHERE row_num > 1 );


-- Delete unused columns

ALTER TABLE housing_data.nashvillehousing
DROP COLUMN TaxDistrict