import React, { useState, useEffect, useRef } from "react";
import axios from "axios";

export const ImageUpload = () => {
  const [selectedFile, setSelectedFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const [data, setData] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const fileInputRef = useRef(null);

  // Cognito Mock Login
  const handleLogin = (e) => {
    e.preventDefault();
    // Here we would integrate actual AWS Cognito using amazon-cognito-identity-js or amplify
    setIsAuthenticated(true);
  };

  const sendFile = async (file) => {
    setIsLoading(true);
    let formData = new FormData();
    formData.append("file", file);
    try {
      let res = await axios({
        method: "post",
        url: process.env.REACT_APP_API_URL || "http://localhost:8000/predict",
        data: formData,
      });
      if (res.status === 200) {
        setData(res.data);
      }
    } catch (err) {
      console.error(err);
      alert("Error connecting to backend.");
    }
    setIsLoading(false);
  };

  const clearData = () => {
    setData(null);
    setSelectedFile(null);
    setPreview(null);
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  const onSelectFile = (e) => {
    if (!e.target.files || e.target.files.length === 0) {
      return;
    }
    const file = e.target.files[0];
    setSelectedFile(file);
    setData(null);
    const objectUrl = URL.createObjectURL(file);
    setPreview(objectUrl);
    sendFile(file);
  };

  if (!isAuthenticated) {
    return (
      <div className="auth-wrapper">
        <div className="glass-card auth-card">
          <h2 style={{ textAlign: "center", marginBottom: "2rem", color: "var(--primary)" }}>Sign In</h2>
          <p style={{ textAlign: "center", color: "var(--text-muted)", marginBottom: "2rem" }}>
            AWS Cognito Authentication
          </p>
          <form onSubmit={handleLogin}>
            <input type="email" placeholder="Email" className="input-field" required />
            <input type="password" placeholder="Password" className="input-field" required />
            <button type="submit" className="btn" style={{ width: "100%" }}>Sign In</button>
          </form>
        </div>
      </div>
    );
  }

  let confidence = 0;
  if (data && data.confidence) {
    confidence = (parseFloat(data.confidence) * 100).toFixed(2);
  }

  return (
    <>
      <nav className="navbar">
        <h1 className="logo-text">AgriSmart AI</h1>
        <div style={{ display: "flex", gap: "1rem", alignItems: "center" }}>
          <span style={{ color: "var(--text-muted)" }}>Farmer Portal</span>
          <div style={{ width: "40px", height: "40px", borderRadius: "50%", background: "var(--primary)", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: "bold" }}>
            AG
          </div>
        </div>
      </nav>

      <div className="app-container">
        {!preview && !isLoading && (
          <div className="upload-container">
            <div style={{ textAlign: "center", maxWidth: "600px" }}>
              <h2 style={{ fontSize: "2.5rem", marginBottom: "1rem" }}>Potato Disease Classifier</h2>
              <p style={{ color: "var(--text-muted)", fontSize: "1.2rem", lineHeight: "1.5" }}>
                Upload an image of a potato leaf to instantly identify diseases like Early Blight or Late Blight, powered by AI.
              </p>
            </div>

            <div className="upload-box glass-card" onClick={() => fileInputRef.current.click()}>
              <div className="upload-icon">📷</div>
              <h3>Click or drag to upload</h3>
              <p style={{ color: "var(--text-muted)" }}>Supports JPG, PNG</p>
              <input
                type="file"
                ref={fileInputRef}
                style={{ display: "none" }}
                accept="image/*"
                onChange={onSelectFile}
              />
            </div>
          </div>
        )}

        {isLoading && (
          <div className="upload-container" style={{ marginTop: "10rem" }}>
            <div className="loader"></div>
            <h3>Analyzing Leaf Structure...</h3>
            <p style={{ color: "var(--text-muted)" }}>Running deep learning models</p>
          </div>
        )}

        {preview && data && !isLoading && (
          <div className="result-container">
            <div className="image-preview glass-card">
              <img src={preview} alt="Uploaded Leaf" />
            </div>

            <div className="result-details glass-card">
              <p style={{ textTransform: "uppercase", letterSpacing: "2px", color: "var(--text-muted)", margin: "0 0 0.5rem 0" }}>Diagnosis Result</p>
              <h2 className="disease-name">{data.disease}</h2>
              <div className="confidence">Confidence Score: <strong>{confidence}%</strong></div>
              
              <div className="advice-box">
                <h4 style={{ margin: "0 0 0.5rem 0", display: "flex", alignItems: "center", gap: "0.5rem" }}>
                  <span>🌱</span> Agronomist Advice (AWS Bedrock)
                </h4>
                <p style={{ margin: 0 }}>{data.advice}</p>
              </div>

              <button className="btn" onClick={clearData}>Scan Another Leaf</button>
            </div>
          </div>
        )}
      </div>
    </>
  );
};

