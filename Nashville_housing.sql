/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM nashvillehousing;

-- Populate Property Address Data

SELECT *
FROM nashvillehousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT a.ParcelID, b.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

-- Breaking out Address into Indivlual Columns(Address, City, State)

SELECT PropertyAddress
FROM nashvillehousing;
-- WHERE PropertyAddress is null
-- ORDER BY ParcelID;

SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Street,
    TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1)) AS City
FROM nashvillehousing;

-- Add new columns
ALTER TABLE nashvillehousing
ADD COLUMN Street VARCHAR(255);

UPDATE nashvillehousing
SET Street =  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE nashvillehousing
ADD COLUMN City   VARCHAR(255);

UPDATE nashvillehousing
SET City = TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1)); 

SELECT *
FROM nashvillehousing;

SELECT OwnerAddress
FROM nashvillehousing;

SELECT
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),               -- Street
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),  -- City
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1))              -- State
FROM nashvillehousing;


-- Add the new columns
ALTER TABLE nashvillehousing
ADD COLUMN OwnerStreet VARCHAR(255),
ADD COLUMN OwnerCity VARCHAR(255),
ADD COLUMN State VARCHAR(50);
ADD COLUMN OwnerSplitAddress VARCHAR(255);

-- Populate Street
UPDATE nashvillehousing
SET OwnerStreet = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1))
WHERE PropertyAddress LIKE '%,%';

-- Populate City
UPDATE nashvillehousing
SET OwnerCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1))
WHERE PropertyAddress LIKE '%,%';

-- Populate OwnerSplitAddress as a combined string (Street | City)
UPDATE nashvillehousing
SET OwnerSplitAddress = CONCAT(
    TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)), ' | ',
    TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1))
)
WHERE PropertyAddress LIKE '%,%';

-- Add the new columns


-- Populate Street, City, and State
UPDATE nashvillehousing
SET 
    Street = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
    City   = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
    State  = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)),
    OwnerSplitAddress = CONCAT(
        TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)), ' | ',
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)), ' | ',
        TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1))
    )
WHERE OwnerAddress LIKE '%,%,%';

-- Drop Owner Split Address
ALTER TABLE nashvillehousing
DROP COLUMN OwnerSplitAddress;




-- Chane Y and N yo Yes and No in 'SOld as Vacant" field

SELECT Distinct (SoldAsVacant), count(SoldAsVacant)
FROM nashvillehousing
Group by SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
    END;



-- Remove Duplicates

DELETE nh
FROM nashvillehousing nh
JOIN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID,
                                PropertyAddress,
                                SalePrice,
                                SaleDate,
                                LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM nashvillehousing
    ) t
    WHERE row_num > 1
) dup
ON nh.UniqueID = dup.UniqueID;


-- Delete Unused Columns

SELECT *
FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress;

ALTER TABLE nashvillehousing
DROP COLUMN TaxDistrict;

ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress;

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate;

















