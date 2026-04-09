import { UserRoles } from "@common/types";

export interface JwtPayload {
  sub: string;
  phone?: string;
  role?: UserRoles;
}
