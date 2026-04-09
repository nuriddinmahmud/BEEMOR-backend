import { Type } from "class-transformer";
import {
  IsLatitude,
  IsLongitude,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from "class-validator";

export class CreateHouseholdDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  address!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  cadastralNumber?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  landmark?: string;

  @Type(() => Number)
  @IsLatitude()
  latitude!: number;

  @Type(() => Number)
  @IsLongitude()
  longitude!: number;

  @IsString()
  @IsNotEmpty()
  districtId!: string;

  @IsString()
  @IsNotEmpty()
  branchId!: string;
}
