```
curl -X POST http://127.0.0.1:8000/preset/image/ -F "query=What would the founder of the brand of the car on the left say to the founder of the brand of the car on the right?" -F "image=@/raid/ViperGPT-Hominis/viper_hominis/test/car.jpeg"
```

```
curl -X POST http://ip:8000/preset/image/ -F "query=What would the founder of the brand of the car on the left say to the founder of the brand of the car on the right?" -F "image=@/raid/ViperGPT-Hominis/viper_hominis/test/car.jpeg"
```

```
docker run --gpus all -it -p 8000:8000 --name viperhominis-updated-container viperhominis-updated bash
```
