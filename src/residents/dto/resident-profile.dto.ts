import {
  IsDateString,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from "class-validator";

export class ResidentProfileDto {
  @IsString()
  @IsNotEmpty()
  householdId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  firstName!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  lastName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  middleName?: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  fullName!: string;

  @IsOptional()
  @Matches(/^\+?[0-9]{7,15}$/)
  phone?: string;

  @IsOptional()
  @IsDateString()
  dateOfBirth?: string;
}
