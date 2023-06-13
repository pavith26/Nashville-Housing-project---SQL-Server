use Nashville_housing

select *
from Nashville_housing_data


-- Standardise data format

alter table Nashville_housing_data
alter column SaleDate date


-- Enter missing property address data

select PropertyAddress
from Nashville_housing_data
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_housing_data a
join Nashville_housing_data b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_housing_data a
join Nashville_housing_data b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


-- Splitting PropertyAddress into individual columns (Address, City)

select PropertyAddress
from Nashville_housing_data

select distinct PropertyAddress
from Nashville_housing_data

select substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
	substring(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress)) as City
from Nashville_housing_data

alter table Nashville_housing_data
add PropertySplitAddress varchar(255), PropertyCity varchar(255)

update Nashville_housing_data
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1),
	PropertyCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress))


-- Splitting OwnerAddress into individual columns (Address, City, State)

select OwnerAddress
from Nashville_housing_data

select distinct OwnerAddress
from Nashville_housing_data

select PARSENAME(replace(OwnerAddress, ',', '.'), 3) as Address,
	PARSENAME(replace(OwnerAddress, ',', '.'), 2) as City,
	PARSENAME(replace(OwnerAddress, ',', '.'), 1) as State
from Nashville_housing_data

alter table Nashville_housing_data
add OwnerSplitAddress varchar(255), OwnerCity varchar(255), OwnerState varchar(255)

update Nashville_housing_data
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3),
	OwnerCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2),
	OwnerState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in SoldAsVacant

select SoldAsVacant
from Nashville_housing_data

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from Nashville_housing_data
group by SoldAsVacant
order by 2

select SoldAsVacant, 
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from Nashville_housing_data

update Nashville_housing_data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


-- Remove duplicates

with Row_Num_CTE as(
select *,
	row_number() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	order by UniqueID
	) row_num
from Nashville_housing_data
)
select *
from Row_Num_CTE
where row_num > 1
order by PropertyAddress

with Row_Num_CTE as(
select *,
	row_number() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	order by UniqueID
	) row_num
from Nashville_housing_data
)
delete
from Row_Num_CTE
where row_num > 1