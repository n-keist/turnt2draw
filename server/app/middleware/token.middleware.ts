import { NextFunction, Request, Response } from 'express';

export default (request: Request, _response: Response, next: NextFunction) => {
    const drawToken = request.header('x-draw-token');
    if (drawToken !== process.env.TOKEN) return next(new Error('INVALID_TOKEN'));
    return next();
};