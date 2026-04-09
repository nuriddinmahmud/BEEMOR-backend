import { Type } from "class-transformer";
import {
  IsEnum,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  MaxLength,
} from "class-validator";

import { SessionStatus } from "@common/types";

export class UpdateDriverStatusDto {
  @IsEnum(SessionStatus)
  status!: SessionStatus;

  @IsOptional()
  @Type(() => Number)
  @IsLatitude()
  latitude?: number;

  @IsOptional()
  @Type(() => Number)
  @IsLongitude()
  longitude?: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  note?: string;
}
