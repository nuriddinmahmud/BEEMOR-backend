import "dotenv/config";

import * as bcrypt from "bcrypt";
import { Prisma, PrismaClient, UserRole } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const prisma = new PrismaClient({
  adapter: new PrismaPg({
    connectionString: process.env.DATABASE_URL ?? "",
  }),
});

const DEFAULT_PASSWORD = "Beemor123!";
const PASSWORD_ROUNDS = 10;

async function main(): Promise<void> {
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is not configured.");
  }

  const passwordHash = await bcrypt.hash(DEFAULT_PASSWORD, PASSWORD_ROUNDS);

  const region = await prisma.region.upsert({
    where: {
      name: "Farg'ona viloyati",
    },
    update: {},
    create: {
      name: "Farg'ona viloyati",
    },
  });

  const district = await prisma.district.upsert({
    where: {
      regionId_name: {
        regionId: region.id,
        name: "Farg'ona shahri",
      },
    },
    update: {},
    create: {
      regionId: region.id,
      name: "Farg'ona shahri",
    },
  });

  const branch = await prisma.branch.upsert({
    where: {
      code: "FGN-EMS-001",
    },
    update: {
      districtId: district.id,
      name: "Farg'ona ShTYo Filiali 1",
      address: "Farg'ona shahri, Mustaqillik ko'chasi 15-uy",
      phone: "+998732440103",
      latitude: decimal("40.3894000"),
      longitude: decimal("71.7833000"),
    },
    create: {
      districtId: district.id,
      name: "Farg'ona ShTYo Filiali 1",
      code: "FGN-EMS-001",
      address: "Farg'ona shahri, Mustaqillik ko'chasi 15-uy",
      phone: "+998732440103",
      latitude: decimal("40.3894000"),
      longitude: decimal("71.7833000"),
    },
  });

  const superAdmin = await upsertUser({
    username: "superadmin",
    phone: "+998900000001",
    firstName: "System",
    lastName: "Owner",
    middleName: "BEEMOR",
    role: UserRole.SUPER_ADMIN,
    passwordHash,
  });

  const admin = await upsertUser({
    username: "admin",
    phone: "+998900000002",
    firstName: "Regional",
    lastName: "Admin",
    middleName: "Fargona",
    role: UserRole.ADMIN,
    districtId: district.id,
    branchId: branch.id,
    passwordHash,
  });

  const driver = await upsertUser({
    username: "driver.test",
    phone: "+998900000003",
    firstName: "Test",
    lastName: "Driver",
    middleName: "Ambulance",
    role: UserRole.DRIVER,
    districtId: district.id,
    branchId: branch.id,
    passwordHash,
  });

  const agent = await upsertUser({
    username: "agent.test",
    phone: "+998900000004",
    firstName: "Test",
    lastName: "Agent",
    middleName: "Registry",
    role: UserRole.AGENT,
    districtId: district.id,
    branchId: branch.id,
    passwordHash,
  });

  const [regionCount, districtCount, branchCount, userCount] = await Promise.all([
    prisma.region.count(),
    prisma.district.count(),
    prisma.branch.count(),
    prisma.user.count(),
  ]);

  console.log("Seed completed successfully.");
  console.log(`Region: ${region.name} (id=${region.id})`);
  console.log(`District: ${district.name} (id=${district.id})`);
  console.log(`Branch: ${branch.name} (id=${branch.id}, code=${branch.code ?? "n/a"})`);
  console.log(
    `Users: super_admin=${superAdmin.username}, admin=${admin.username}, driver=${driver.username}, agent=${agent.username}`,
  );
  console.log(`Counts => regions=${regionCount}, districts=${districtCount}, branches=${branchCount}, users=${userCount}`);
  console.log(`Default password for seeded users: ${DEFAULT_PASSWORD}`);
}

type SeedUserInput = {
  username: string;
  phone: string;
  firstName: string;
  lastName: string;
  middleName?: string;
  role: UserRole;
  districtId?: number;
  branchId?: number;
  passwordHash: string;
};

async function upsertUser(input: SeedUserInput) {
  const { username, phone, firstName, lastName, middleName, role, districtId, branchId, passwordHash } = input;

  return prisma.user.upsert({
    where: {
      username,
    },
    update: {
      phone,
      firstName,
      lastName,
      middleName,
      role,
      districtId,
      branchId,
      passwordHash,
      isActive: true,
    },
    create: {
      username,
      phone,
      firstName,
      lastName,
      middleName,
      role,
      districtId,
      branchId,
      passwordHash,
      isActive: true,
    },
  });
}

function decimal(value: string): Prisma.Decimal {
  return new Prisma.Decimal(value);
}

main()
  .catch((error: unknown) => {
    console.error("Seed failed.");
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
