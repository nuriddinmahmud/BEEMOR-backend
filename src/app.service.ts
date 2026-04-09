import { Injectable } from "@nestjs/common";

@Injectable()
export class AppService {
  getHealthCheck() {
    return {
      service: "BEEMOR Ambulance Address Registry",
      status: "ok",
      timestamp: new Date().toISOString(),
    };
  }
}
