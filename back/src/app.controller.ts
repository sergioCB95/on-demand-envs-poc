import {Body, Controller, Get, Post} from '@nestjs/common';
import { AppService } from './app.service';
import { User } from '@prisma/client';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getAll(): Promise<User[]> {
    return this.appService.getAll();
  }

  @Post()
  post(@Body() user: User): Promise<void> {
    return this.appService.post(user);
  }
}
