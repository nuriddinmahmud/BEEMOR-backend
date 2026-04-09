import { ValidationPipe } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { NestFactory } from "@nestjs/core";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";

import { AppModule } from "./app.module";

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  const globalPrefix = "api/v1";

  app.setGlobalPrefix(globalPrefix);
  app.enableCors({
    origin: resolveCorsOrigins(configService.get<string>("CORS_ORIGIN")),
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  const swaggerConfig = new DocumentBuilder()
    .setTitle("BEEMOR API")
    .setDescription("Backend API for the BEEMOR address registry and ambulance navigation system.")
    .setVersion("1.0.0")
    .addBearerAuth(
      {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
        description: "Paste the JWT access token here.",
      },
      "access-token",
    )
    .build();

  const swaggerDocument = SwaggerModule.createDocument(app, swaggerConfig);

  SwaggerModule.setup(`${globalPrefix}/docs`, app, swaggerDocument, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

  await app.listen(configService.get<number>("PORT") ?? 3000);
}

function resolveCorsOrigins(corsOrigin?: string): true | string[] {
  if (!corsOrigin || corsOrigin === "*") {
    return true;
  }

  return corsOrigin
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}

bootstrap();
