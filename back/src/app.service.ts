import { Injectable } from '@nestjs/common';
import {PrismaService} from "./prisma.service";
import { User } from '@prisma/client';

@Injectable()
export class AppService {
  constructor(private prisma: PrismaService) {}
  async getAll(): Promise<User[]> {
    return this.prisma.user.findMany();
  }
}
