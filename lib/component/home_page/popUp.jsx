import { useState, useEffect } from "react";

const Popup = ({ popupImages }) => {
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    // Check if the popup has been shown in this session
    const hasPopupBeenShown = sessionStorage.getItem("popupShown");

    if (!hasPopupBeenShown) {
      setIsOpen(true); // Show the popup if it hasn't been shown in this session
    }
  }, []);

  const closePopup = () => {
    setIsOpen(false); // Hide the popup
    sessionStorage.setItem("popupShown", "true"); // Set the flag to indicate the popup has been shown in this session
  };

  if (!popupImages.length || !popupImages[0]?.imageUrl) return null;

  return (
    isOpen && (
      <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-70 z-50">
        <div className="relative bg-white p-4 md:p-6 rounded-lg shadow-lg max-w-sm md:max-w-md w-full">
          {/* Close Button */}
          <button
            onClick={closePopup}
            className="absolute top-2 right-3 text-xl font-bold text-gray-600 hover:text-gray-900"
          >
            &times;
          </button>

          {/* Image */}
          <img
            src={popupImages[0].imageUrl} // Replace with your image URL
            alt="Popup"
            className="w-full h-auto rounded-md"
          />
        </div>
      </div>
    )
  );
};

export default Popup;