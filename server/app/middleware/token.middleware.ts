import { NextFunction, Request, Response } from 'express';

export default (request: Request, response: Response, next: NextFunction) => {
    const drawToken = request.header('x-draw-token');
    if (drawToken !== process.env.TOKEN) return response.status(401).end();
    return next();
};