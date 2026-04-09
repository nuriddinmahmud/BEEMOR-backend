import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";

import { AuditModule } from "./audit/audit.module";
import { AuthModule } from "./auth/auth.module";
import { AppController } from "./app.controller";
import { AppService } from "./app.service";
import { BranchesModule } from "./branches/branches.module";
import { HouseholdsModule } from "./households/households.module";
import { NavigationModule } from "./navigation/navigation.module";
import { PrismaModule } from "./common/prisma/prisma.module";
import { validateEnv } from "./config/env.validation";
import { RegionsModule } from "./regions/regions.module";
import { ResidentsModule } from "./residents/residents.module";
import { SearchModule } from "./search/search.module";
import { UsersModule } from "./users/users.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      validate: validateEnv,
    }),
    PrismaModule,
    AuthModule,
    UsersModule,
    RegionsModule,
    BranchesModule,
    HouseholdsModule,
    ResidentsModule,
    SearchModule,
    NavigationModule,
    AuditModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
